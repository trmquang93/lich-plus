//
//  NonceGenerator.swift
//  lich-plus
//
//  Utility for generating unique nonces to prevent replay attacks
//

import Foundation

/// Generates unique nonces for API requests to prevent replay attacks
enum NonceGenerator {
    /// Generate a unique nonce with format: {uuid}:{timestamp_ms}
    /// - Returns: A nonce string combining UUID and current timestamp
    static func generate() -> String {
        let uuid = UUID().uuidString.lowercased()
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        return "\(uuid):\(timestamp)"
    }
}
