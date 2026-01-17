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

        // Default: nil (will use offline mode)
        // In production, set this to your Firebase/Supabase function URL:
        // return URL(string: "https://your-project.cloudfunctions.net/generateGreeting")
        // return URL(string: "https://your-project.supabase.co/functions/v1/generate-greeting")
        return nil
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
        // If backend not configured, use offline samples
        guard let backendURL = GreetingServiceConfig.backendURL else {
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
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = GreetingServiceConfig.requestTimeout

        // Build request payload
        let payload = GreetingAPIRequest(
            recipientType: request.recipientType.rawValue,
            tone: request.tone.rawValue,
            occasion: request.occasion.rawValue,
            recipientName: request.recipientName,
            year: request.year
        )

        urlRequest.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GreetingServiceError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            let decodedResponse = try JSONDecoder().decode(GreetingAPIResponse.self, from: data)

            if let error = decodedResponse.error {
                throw GreetingServiceError.serverError(error)
            }

            guard let greeting = decodedResponse.greeting else {
                throw GreetingServiceError.invalidResponse
            }

            return greeting.trimmingCharacters(in: .whitespacesAndNewlines)

        case 401, 403:
            throw GreetingServiceError.unauthorized

        case 429:
            throw GreetingServiceError.rateLimited

        case 500...599:
            // Try to parse error message from response
            if let errorResponse = try? JSONDecoder().decode(GreetingAPIResponse.self, from: data),
               let errorMessage = errorResponse.error {
                throw GreetingServiceError.serverError(errorMessage)
            }
            throw GreetingServiceError.serverError("Internal server error")

        default:
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
    let year: Int
}

/// Response from backend function
struct GreetingAPIResponse: Codable {
    /// Generated greeting text (on success)
    let greeting: String?

    /// Error message (on failure)
    let error: String?
}
