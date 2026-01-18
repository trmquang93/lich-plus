//
//  SupabaseService.swift
//  lich-plus
//
//  Service for managing Supabase authentication using official SDK
//

import Foundation
import Supabase

// MARK: - Supabase Service Error

enum SupabaseServiceError: LocalizedError {
    case noSession
    case authenticationFailed(String)

    var errorDescription: String? {
        switch self {
        case .noSession:
            return "No valid session"
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        }
    }
}

// MARK: - Supabase Service

/// Service for managing Supabase anonymous authentication using official SDK
@MainActor
final class SupabaseService {
    static let shared = SupabaseService()

    let client: SupabaseClient

    private init() {
        guard let projectID = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_PROJECT_ID") as? String,
              let anonKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String else {
            fatalError("SUPABASE_PROJECT_ID or SUPABASE_ANON_KEY not found in Info.plist. Please create Config.xcconfig with your Supabase credentials.")
        }

        let supabaseURL = URL(string: "https://\(projectID).supabase.co")!
        client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: anonKey)
    }

    // MARK: - Public Methods

    /// Ensure we have a valid anonymous session
    /// Creates a new session if none exists, SDK handles token refresh automatically
    func ensureAnonymousSession() async throws {
        // Check if already signed in (SDK handles session persistence and refresh)
        if let session = try? await client.auth.session {
            return
        }

        // Sign in anonymously
        do {
            let session = try await client.auth.signInAnonymously()
        } catch {
            throw SupabaseServiceError.authenticationFailed(error.localizedDescription)
        }
    }

    /// Get the current access token
    /// Throws an error if no valid session exists
    func getAccessToken() async throws -> String {
        try await ensureAnonymousSession()

        guard let session = try? await client.auth.session else {
            throw SupabaseServiceError.noSession
        }

        return session.accessToken
    }
}
