//
//  GreetingService.swift
//  lich-plus
//
//  Created by Claude on 17/01/26.
//

import Foundation

// MARK: - Greeting Service Error

enum GreetingServiceError: LocalizedError {
    case networkError(Error)
    case invalidResponse
    case rateLimited
    case serverError(String)
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Lỗi mạng: \(error.localizedDescription)"
        case .invalidResponse:
            return "Phản hồi không hợp lệ"
        case .rateLimited:
            return "Quá nhiều yêu cầu, vui lòng thử lại sau"
        case .serverError(let message):
            return "Lỗi server: \(message)"
        case .unauthorized:
            return "Không có quyền truy cập"
        }
    }
}

// MARK: - Greeting Service Configuration

/// Configuration for the greeting service backend
struct GreetingServiceConfig {
    /// Backend function URL (Firebase/Supabase)
    /// Set this to your deployed function URL
    static var backendURL: URL? {
        // Try to get from environment or use default
        if let urlString = ProcessInfo.processInfo.environment["GREETING_API_URL"],
           let url = URL(string: urlString) {
            return url
        }

        // Production Supabase Edge Function URL
        return URL(string: "https://jlqycjwtiabjsfldhzwt.supabase.co/functions/v1/generate-greeting")
    }


    /// Request timeout in seconds
    static let requestTimeout: TimeInterval = 30

    /// Whether to use offline fallback when backend is unavailable
    static let useOfflineFallback: Bool = true
}

// MARK: - Greeting Service

/// Service for generating greeting messages via backend function
/// The backend forwards requests to Claude API, keeping the API key secure
class GreetingService {

    // MARK: - Initialization

    init() {}

    // MARK: - Public Methods

    /// Check if backend is configured
    var isBackendConfigured: Bool {
        GreetingServiceConfig.backendURL != nil
    }

    /// Generate a greeting message
    /// - Parameter request: The greeting request with recipient type, tone, etc.
    /// - Returns: Generated greeting text
    func generateGreeting(for request: GreetingRequest) async throws -> String {
        print("\n========================================")
        print("🎉 [GreetingService] Generate Greeting Request")
        print("========================================")
        print("Recipient: \(request.recipientType.rawValue)")
        print("Tone: \(request.tone.rawValue)")
        print("Occasion: \(request.occasion.rawValue)")
        print("Year: \(request.year)")
        if let name = request.recipientName {
            print("Name: \(name)")
        }
        if let info = request.additionalInfo {
            print("Additional info: \(info)")
        }
        print("========================================\n")

        // If backend not configured, use offline samples
        guard let backendURL = GreetingServiceConfig.backendURL else {
            print("⚠️  [GreetingService] Backend URL not configured, using offline greeting")
            return generateOfflineGreeting(for: request)
        }

        return try await callBackendFunction(url: backendURL, request: request)
    }

    /// Generate greeting using offline samples (fallback)
    func generateOfflineGreeting(for request: GreetingRequest) -> String {
        return SampleGreetings.randomGreeting(for: request)
    }

    // MARK: - Private Methods

    private func callBackendFunction(url: URL, request: GreetingRequest) async throws -> String {
        print("🌟 [GreetingService] Starting greeting generation...")
        print("   URL: \(url.absoluteString)")

        // Get authenticated JWT token (not static anon key)
        let accessToken = try await SupabaseService.shared.getAccessToken()
        let tokenPreview = String(accessToken.prefix(50))
        print("   Token preview: \(tokenPreview)...")

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.timeoutInterval = GreetingServiceConfig.requestTimeout

        // Build request payload
        let payload = GreetingAPIRequest(
            recipientType: request.recipientType.rawValue,
            tone: request.tone.rawValue,
            occasion: request.occasion.rawValue,
            recipientName: request.recipientName,
            additionalInfo: request.additionalInfo,
            year: request.year
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        urlRequest.httpBody = try encoder.encode(payload)

        if let jsonString = String(data: urlRequest.httpBody!, encoding: .utf8) {
            print("   Request payload:\n\(jsonString)")
        }

        print("   Sending request...")
        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ [GreetingService] Invalid HTTP response")
            throw GreetingServiceError.invalidResponse
        }

        print("   Response status: \(httpResponse.statusCode)")

        let responseBody = String(data: data, encoding: .utf8) ?? "Unable to decode response"
        print("   Response body: \(responseBody)")

        switch httpResponse.statusCode {
        case 200:
            let decodedResponse = try JSONDecoder().decode(GreetingAPIResponse.self, from: data)

            if let error = decodedResponse.error {
                print("❌ [GreetingService] Server returned error: \(error)")
                throw GreetingServiceError.serverError(error)
            }

            guard let greeting = decodedResponse.greeting else {
                print("❌ [GreetingService] No greeting in response")
                throw GreetingServiceError.invalidResponse
            }

            print("✅ [GreetingService] Greeting generated successfully")
            print("   Length: \(greeting.count) characters")
            return greeting.trimmingCharacters(in: .whitespacesAndNewlines)

        case 401, 403:
            print("❌ [GreetingService] Unauthorized (status: \(httpResponse.statusCode))")
            throw GreetingServiceError.unauthorized

        case 429:
            print("❌ [GreetingService] Rate limited")
            throw GreetingServiceError.rateLimited

        case 500...599:
            // Try to parse error message from response
            if let errorResponse = try? JSONDecoder().decode(GreetingAPIResponse.self, from: data),
               let errorMessage = errorResponse.error {
                print("❌ [GreetingService] Server error: \(errorMessage)")
                throw GreetingServiceError.serverError(errorMessage)
            }
            print("❌ [GreetingService] Internal server error")
            throw GreetingServiceError.serverError("Internal server error")

        default:
            print("❌ [GreetingService] Unexpected status code: \(httpResponse.statusCode)")
            throw GreetingServiceError.networkError(
                NSError(domain: "HTTP", code: httpResponse.statusCode, userInfo: nil)
            )
        }
    }
}

// MARK: - API Request/Response Models

/// Request payload sent to backend function
struct GreetingAPIRequest: Codable {
    let recipientType: String
    let tone: String
    let occasion: String
    let recipientName: String?
    let additionalInfo: String?
    let year: Int
}

/// Response from backend function
struct GreetingAPIResponse: Codable {
    /// Generated greeting text (on success)
    let greeting: String?

    /// Error message (on failure)
    let error: String?
}
