//
//  SupabaseService.swift
//  lich-plus
//
//  Service for managing Supabase authentication via REST API
//

import Foundation

// MARK: - Supabase Session Models

struct SupabaseSession: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let expiresAt: Double
    let user: SupabaseUser

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case expiresAt = "expires_at"
        case user
    }

    var isExpired: Bool {
        Date().timeIntervalSince1970 >= expiresAt
    }
}

struct SupabaseUser: Codable {
    let id: String
    let role: String
}

struct SupabaseAuthResponse: Decodable {
    let session: SupabaseSession?
    let user: SupabaseUser?

    enum CodingKeys: String, CodingKey {
        case session
        case user
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case expiresAt = "expires_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Try nested "session" first (for token refresh responses)
        if let nestedSession = try? container.decode(SupabaseSession.self, forKey: .session) {
            self.session = nestedSession
            self.user = try? container.decode(SupabaseUser.self, forKey: .user)
        }
        // Otherwise, try root-level session fields (for anonymous signup)
        else if let accessToken = try? container.decode(String.self, forKey: .accessToken),
                let refreshToken = try? container.decode(String.self, forKey: .refreshToken),
                let expiresIn = try? container.decode(Int.self, forKey: .expiresIn),
                let expiresAt = try? container.decode(Double.self, forKey: .expiresAt),
                let user = try? container.decode(SupabaseUser.self, forKey: .user) {
            self.session = SupabaseSession(
                accessToken: accessToken,
                refreshToken: refreshToken,
                expiresIn: expiresIn,
                expiresAt: expiresAt,
                user: user
            )
            self.user = user
        }
        // No valid session data found
        else {
            self.session = nil
            self.user = try? container.decode(SupabaseUser.self, forKey: .user)
        }
    }
}

struct SupabaseErrorResponse: Codable {
    let error: String?
    let errorDescription: String?

    enum CodingKeys: String, CodingKey {
        case error
        case errorDescription = "error_description"
    }
}

// MARK: - Supabase Service Error

enum SupabaseServiceError: LocalizedError {
    case networkError(Error)
    case invalidResponse
    case authenticationFailed(String)
    case noSession

    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        case .noSession:
            return "No valid session"
        }
    }
}

// MARK: - Supabase Service

/// Service for managing Supabase anonymous authentication
@MainActor
final class SupabaseService {
    static let shared = SupabaseService()

    private let supabaseURL = "https://jlqycjwtiabjsfldhzwt.supabase.co"
    private let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpscXljand0aWFianNmbGRoend0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg2NzE2ODYsImV4cCI6MjA4NDI0NzY4Nn0.3K75jdXDYAPnku4JYW_lf9nl3i9Z2X2Rwwm00A1I9MA"

    private let sessionKey = "supabase_session"
    private var cachedSession: SupabaseSession?

    private init() {
        // Load cached session from UserDefaults
        loadCachedSession()
    }

    // MARK: - Public Methods

    /// Ensure we have a valid anonymous session
    /// Creates a new session if none exists or if the current one is expired
    func ensureAnonymousSession() async throws {
        print("🔍 [SupabaseService] Checking session validity...")

        // Check if we have a valid cached session
        if let session = cachedSession, !session.isExpired {
            print("✅ [SupabaseService] Valid cached session found")
            print("   User ID: \(session.user.id)")
            print("   Expires: \(Date(timeIntervalSince1970: session.expiresAt))")
            return
        }

        // Try to refresh if we have a refresh token
        if let session = cachedSession, session.isExpired {
            print("⏰ [SupabaseService] Session expired, attempting refresh...")
            do {
                try await refreshSession(refreshToken: session.refreshToken)
                return
            } catch {
                print("⚠️  [SupabaseService] Failed to refresh session, creating new one: \(error)")
            }
        }

        // Create new anonymous session
        if cachedSession == nil {
            print("📭 [SupabaseService] No cached session, creating new one...")
        }
        try await signInAnonymously()
    }

    /// Get the current access token
    /// Throws an error if no valid session exists
    func getAccessToken() async throws -> String {
        print("🔑 [SupabaseService] Getting access token...")

        try await ensureAnonymousSession()

        guard let session = cachedSession else {
            print("❌ [SupabaseService] No cached session available")
            throw SupabaseServiceError.noSession
        }

        let tokenPreview = String(session.accessToken.prefix(50))
        print("✅ [SupabaseService] Access token retrieved: \(tokenPreview)...")
        print("   User ID: \(session.user.id)")
        print("   Expires at: \(Date(timeIntervalSince1970: session.expiresAt))")
        print("   Is expired: \(session.isExpired)")

        return session.accessToken
    }

    // MARK: - Private Methods

    /// Sign in anonymously to create a new session
    private func signInAnonymously() async throws {
        print("🔐 [SupabaseService] Creating new anonymous session...")

        let url = URL(string: "\(supabaseURL)/auth/v1/signup")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")

        // Request body for anonymous sign-in
        let body: [String: Any] = [:]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        print("   URL: \(url.absoluteString)")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ [SupabaseService] Invalid HTTP response")
            throw SupabaseServiceError.invalidResponse
        }

        print("   Response status: \(httpResponse.statusCode)")

        guard httpResponse.statusCode == 200 else {
            let errorResponse = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data)
            let errorMessage = errorResponse?.errorDescription ?? errorResponse?.error ?? "Unknown error"
            let responseBody = String(data: data, encoding: .utf8) ?? "Unable to decode response"
            print("❌ [SupabaseService] Auth failed: \(errorMessage)")
            print("   Response body: \(responseBody)")
            throw SupabaseServiceError.authenticationFailed(errorMessage)
        }

        let authResponse = try JSONDecoder().decode(SupabaseAuthResponse.self, from: data)

        guard let session = authResponse.session else {
            print("❌ [SupabaseService] No session in auth response")
            throw SupabaseServiceError.authenticationFailed("No session in response")
        }

        print("✅ [SupabaseService] Anonymous session created successfully")
        print("   User ID: \(session.user.id)")

        // Cache the session
        cachedSession = session
        saveCachedSession(session)
    }

    /// Refresh an existing session using a refresh token
    private func refreshSession(refreshToken: String) async throws {
        let url = URL(string: "\(supabaseURL)/auth/v1/token?grant_type=refresh_token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")

        let body = ["refresh_token": refreshToken]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseServiceError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let errorResponse = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data)
            let errorMessage = errorResponse?.errorDescription ?? errorResponse?.error ?? "Unknown error"
            throw SupabaseServiceError.authenticationFailed(errorMessage)
        }

        let authResponse = try JSONDecoder().decode(SupabaseAuthResponse.self, from: data)

        guard let session = authResponse.session else {
            throw SupabaseServiceError.authenticationFailed("No session in response")
        }

        // Cache the new session
        cachedSession = session
        saveCachedSession(session)
    }

    // MARK: - Session Persistence

    private func loadCachedSession() {
        guard let data = UserDefaults.standard.data(forKey: sessionKey) else {
            return
        }

        do {
            cachedSession = try JSONDecoder().decode(SupabaseSession.self, from: data)
        } catch {
            print("Failed to load cached session: \(error)")
            UserDefaults.standard.removeObject(forKey: sessionKey)
        }
    }

    private func saveCachedSession(_ session: SupabaseSession) {
        do {
            let data = try JSONEncoder().encode(session)
            UserDefaults.standard.set(data, forKey: sessionKey)
        } catch {
            print("Failed to save session: \(error)")
        }
    }
}
