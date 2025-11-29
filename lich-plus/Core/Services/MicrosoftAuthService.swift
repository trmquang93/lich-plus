import Foundation
import Combine

// MSAL is imported via the bridging header (lich-plus-Bridging-Header.h)

@MainActor
class MicrosoftAuthService: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var currentAccount: MSALAccount?
    @Published var userEmail: String?
    @Published var authError: Error?

    private let clientId = "5fe4ebd3-b32c-4686-9a51-ea54b1e05bbf"  // Placeholder
    private let authority = "https://login.microsoftonline.com/common"
    private let redirectUri = "msauth.com.qtran.lich-plus://auth"
    private let scopes = ["Calendars.Read"]

    private var application: MSALPublicClientApplication?

    init() {
        setupApplication()
    }

    private func setupApplication() {
        MSALGlobalConfig.brokerAvailability = .none

        guard let authorityURL = URL(string: authority) else { return }

        do {
            let authority = try MSALAADAuthority(url: authorityURL)
            let config = MSALPublicClientApplicationConfig(
                clientId: clientId,
                redirectUri: redirectUri,
                authority: authority
            )
            application = try MSALPublicClientApplication(configuration: config)
        } catch {
            print("Failed to create MSAL application: \(error)")
            authError = error
        }
    }

    /// Sign in with Microsoft, requesting calendar read scope
    func signIn() async throws {
        guard let application = application else {
            throw MicrosoftAuthError.applicationNotInitialized
        }

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw MicrosoftAuthError.noRootViewController
        }

        let webViewParameters = MSALWebviewParameters(authPresentationViewController: rootViewController)
        webViewParameters.webviewType = .wkWebView
        let interactiveParameters = MSALInteractiveTokenParameters(scopes: scopes, webviewParameters: webViewParameters)

        do {
            let result = try await application.acquireToken(with: interactiveParameters)
            self.currentAccount = result.account
            self.userEmail = result.account.username
            self.isSignedIn = true
            self.authError = nil
        } catch {
            self.authError = error
            throw error
        }
    }

    /// Sign out from Microsoft
    func signOut() {
        guard let application = application,
              let account = currentAccount else { return }

        do {
            try application.remove(account)
        } catch {
            print("Failed to sign out: \(error)")
        }

        self.currentAccount = nil
        self.userEmail = nil
        self.isSignedIn = false
        self.authError = nil
    }

    /// Restore previous sign-in on app launch
    func restorePreviousSignIn() async {
        guard let application = application else { return }

        do {
            let accounts = try application.allAccounts()
            if let account = accounts.first {
                // Try to get token silently
                let silentParameters = MSALSilentTokenParameters(scopes: scopes, account: account)
                let result = try await application.acquireTokenSilent(with: silentParameters)

                self.currentAccount = result.account
                self.userEmail = result.account.username
                self.isSignedIn = true
            }
        } catch {
            // Silent token acquisition failed - user needs to sign in again
            self.isSignedIn = false
        }
    }

    /// Get valid access token, refreshing if needed
    func getAccessToken() async throws -> String {
        guard let application = application,
              let account = currentAccount else {
            throw MicrosoftAuthError.notSignedIn
        }

        let silentParameters = MSALSilentTokenParameters(scopes: scopes, account: account)

        do {
            let result = try await application.acquireTokenSilent(with: silentParameters)
            return result.accessToken
        } catch let error as NSError where error.domain == MSALErrorDomain && error.code == MSALError.interactionRequired.rawValue {
            // Token expired, need interactive sign-in
            throw MicrosoftAuthError.tokenExpired
        } catch {
            throw error
        }
    }
}

// MARK: - Errors

enum MicrosoftAuthError: LocalizedError {
    case applicationNotInitialized
    case noRootViewController
    case notSignedIn
    case tokenExpired
    case noAccessToken

    var errorDescription: String? {
        switch self {
        case .applicationNotInitialized:
            return "Microsoft authentication not initialized"
        case .noRootViewController:
            return "Unable to find root view controller for sign-in"
        case .notSignedIn:
            return "User is not signed in to Microsoft"
        case .tokenExpired:
            return "Session expired. Please sign in again."
        case .noAccessToken:
            return "Unable to retrieve access token"
        }
    }
}
