//
//  GreetingService.swift
//  lich-plus
//

import Foundation
import Supabase

// MARK: - Greeting Service Error

enum GreetingServiceError: LocalizedError {
    case networkError(Error)
    case invalidResponse
    case rateLimited
    case serverError(String)
    case unauthorized
    case replayDetected

    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return String(localized: "Network error: \(error.localizedDescription)")
        case .invalidResponse:
            return String(localized: "Invalid response")
        case .rateLimited:
            return String(localized: "Too many requests, please try again later")
        case .serverError(let message):
            return String(localized: "Server error: \(message)")
        case .unauthorized:
            return String(localized: "Access denied")
        case .replayDetected:
            return String(localized: "Invalid request, please try again")
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
        // Use Supabase SDK's built-in function invocation
        // This handles authentication automatically

        // Generate unique nonce to prevent replay attacks
        let nonce = NonceGenerator.generate()

        let payload = GreetingAPIRequest(
            recipientType: request.recipientType.rawValue,
            tone: request.tone.rawValue,
            occasion: request.occasion.rawValue,
            recipientName: request.recipientName,
            additionalInfo: request.additionalInfo,
            year: request.year,
            nonce: nonce
        )

        // Ensure we have a valid session first
        try await SupabaseService.shared.ensureAnonymousSession()

        do {
            // Invoke function and decode response directly
            let greetingResponse: GreetingAPIResponse = try await SupabaseService.shared.client.functions.invoke(
                "generate-greeting",
                options: .init(body: payload)
            )

            if let error = greetingResponse.error {
                throw GreetingServiceError.serverError(error)
            }

            guard let greeting = greetingResponse.greeting else {
                throw GreetingServiceError.invalidResponse
            }

            return greeting.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        } catch let error as FunctionsError {
            throw GreetingServiceError.serverError(error.localizedDescription)
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
    let nonce: String
}

/// Response from backend function
struct GreetingAPIResponse: Codable {
    /// Generated greeting text (on success)
    let greeting: String?

    /// Error message (on failure)
    let error: String?

    /// Error details (for debugging)
    let details: String?
}
