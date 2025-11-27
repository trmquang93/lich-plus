//
//  NLPConfiguration.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 27/11/25.
//

import Foundation

// MARK: - NLP Configuration

/// Configuration for NLP service API key management
struct NLPConfiguration {
    private static let apiKeyUserDefaultsKey = "com.lichplus.nlp.api_key"

    /// Store API key in UserDefaults
    /// - Parameter apiKey: The API key to store
    static func storeAPIKey(_ apiKey: String) {
        UserDefaults.standard.set(apiKey, forKey: apiKeyUserDefaultsKey)
    }

    /// Retrieve stored API key from UserDefaults
    /// - Returns: The stored API key, or nil if not found
    static func retrieveAPIKey() -> String? {
        UserDefaults.standard.string(forKey: apiKeyUserDefaultsKey)
    }

    /// Clear stored API key
    static func clearAPIKey() {
        UserDefaults.standard.removeObject(forKey: apiKeyUserDefaultsKey)
    }

    /// Check if API key is configured
    /// - Returns: True if API key is available
    static func isConfigured() -> Bool {
        retrieveAPIKey() != nil || ProcessInfo.processInfo.environment["CLAUDE_API_KEY"] != nil
    }
}
