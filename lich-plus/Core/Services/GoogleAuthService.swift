import Foundation
import Combine
import GoogleSignIn
import UIKit

@MainActor
class GoogleAuthService: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var currentUser: GIDGoogleUser?
    @Published var userEmail: String?
    @Published var authError: Error?

    private let calendarScope = "https://www.googleapis.com/auth/calendar.readonly"

    init() {
        // Check if user is already signed in
        if let user = GIDSignIn.sharedInstance.currentUser {
            self.currentUser = user
            self.userEmail = user.profile?.email
            self.isSignedIn = true
        }
    }

    /// Sign in with Google, requesting calendar read-only scope
    func signIn() async throws {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw GoogleAuthError.noRootViewController
        }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: rootViewController,
                hint: nil,
                additionalScopes: [calendarScope]
            )

            self.currentUser = result.user
            self.userEmail = result.user.profile?.email
            self.isSignedIn = true
            self.authError = nil
        } catch {
            self.authError = error
            throw error
        }
    }

    /// Sign out from Google
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        self.currentUser = nil
        self.userEmail = nil
        self.isSignedIn = false
        self.authError = nil
    }

    /// Restore previous sign-in on app launch
    func restorePreviousSignIn() async {
        do {
            let user = try await GIDSignIn.sharedInstance.restorePreviousSignIn()
            self.currentUser = user
            self.userEmail = user.profile?.email
            self.isSignedIn = true
        } catch {
            // No previous sign-in or error - this is okay on first launch
            self.isSignedIn = false
        }
    }

    /// Get valid access token, refreshing if needed
    func getAccessToken() async throws -> String {
        guard let user = currentUser else {
            throw GoogleAuthError.notSignedIn
        }

        // Refresh token if needed
        try await user.refreshTokensIfNeeded()

        let accessToken = user.accessToken.tokenString
        if accessToken.isEmpty {
            throw GoogleAuthError.noAccessToken
        }

        return accessToken
    }

    /// Handle URL callback from Google Sign-In
    func handle(_ url: URL) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

// MARK: - Errors

enum GoogleAuthError: LocalizedError {
    case noRootViewController
    case notSignedIn
    case noAccessToken

    var errorDescription: String? {
        switch self {
        case .noRootViewController:
            return "Unable to find root view controller for sign-in"
        case .notSignedIn:
            return "User is not signed in to Google"
        case .noAccessToken:
            return "Unable to retrieve access token"
        }
    }
}
