//
//  RetryUtility.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 01/12/25.
//

import Foundation

// MARK: - Retry Error

/// An error thrown when a retry operation fails unexpectedly.
private struct RetryError: LocalizedError {
    var errorDescription: String? { "Unexpected retry operation failure" }
}

// MARK: - Retry Utility

/// A utility for executing async operations with exponential backoff retry logic.
///
/// This utility automatically retries failed operations when they encounter rate limiting errors
/// from Google Calendar or Microsoft Graph APIs. Other errors are rethrown immediately.
///
/// - Exponential backoff delays: 1s, 2s, 4s, 8s, 16s (with jitter)
/// - Detects rate limit errors from both Google and Microsoft APIs
/// - Only retries on rate limit errors; other errors are rethrown immediately
/// - Adds random jitter (0-0.5s) to prevent thundering herd problem
struct RetryUtility {
    /// Executes an async operation with exponential backoff retry on rate limit errors.
    ///
    /// When a rate limit error is encountered, the operation will be retried with an
    /// exponentially increasing delay between attempts. The delay for each retry is calculated as:
    /// `baseDelay * (2 ^ attemptNumber) + randomJitter`
    ///
    /// For example, with default parameters:
    /// - 1st retry: ~1.0 - 1.5 seconds
    /// - 2nd retry: ~2.0 - 2.5 seconds
    /// - 3rd retry: ~4.0 - 4.5 seconds
    /// - 4th retry: ~8.0 - 8.5 seconds
    /// - 5th retry: ~16.0 - 16.5 seconds
    ///
    /// Non-rate-limit errors are rethrown immediately without retry.
    ///
    /// - Parameters:
    ///   - maxRetries: Maximum number of retry attempts (default: 5)
    ///   - baseDelay: Initial delay in seconds between retries (default: 1.0)
    ///   - operation: The async operation to execute
    ///
    /// - Returns: The result of the operation if successful
    /// - Throws: The last rate limit error if all retries fail, or any non-rate-limit error immediately
    static func withExponentialBackoff<T>(
        maxRetries: Int = 5,
        baseDelay: TimeInterval = 1.0,
        operation: () async throws -> T
    ) async throws -> T {
        var lastError: Error?

        for attempt in 0...maxRetries {
            do {
                return try await operation()
            } catch {
                // Check if this is a rate limit error
                if isRateLimitError(error) {
                    // Only retry if we haven't exhausted our attempts
                    if attempt < maxRetries {
                        lastError = error
                        let delay = calculateDelay(
                            baseDelay: baseDelay,
                            attempt: attempt
                        )
                        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                        continue
                    } else {
                        // All retries exhausted, rethrow the rate limit error
                        throw error
                    }
                } else {
                    // Not a rate limit error, rethrow immediately
                    throw error
                }
            }
        }

        // This should not be reached due to the logic above
        if let lastError = lastError {
            throw lastError
        }

        // Fallback (should not reach here)
        throw RetryError()
    }

    // MARK: - Private Helpers

    /// Determines if an error is a rate limit error from Google or Microsoft APIs.
    ///
    /// - Parameter error: The error to check
    /// - Returns: `true` if the error is a rate limit error, `false` otherwise
    private static func isRateLimitError(_ error: Error) -> Bool {
        // Check for Google Calendar API rate limit error
        if let googleError = error as? GoogleCalendarError {
            if case .rateLimited = googleError {
                return true
            }
        }

        // Check for Microsoft Calendar API rate limit error
        if let microsoftError = error as? MicrosoftCalendarError {
            if case .rateLimited = microsoftError {
                return true
            }
        }

        return false
    }

    /// Calculates the delay for the given attempt number using exponential backoff with jitter.
    ///
    /// The delay is calculated as: `baseDelay * (2 ^ attempt) + randomJitter`
    /// where `randomJitter` is a random value between 0.0 and 0.5 seconds to prevent
    /// the thundering herd problem.
    ///
    /// - Parameters:
    ///   - baseDelay: The base delay in seconds
    ///   - attempt: The current attempt number (0-indexed)
    /// - Returns: The calculated delay in seconds
    private static func calculateDelay(baseDelay: TimeInterval, attempt: Int) -> TimeInterval {
        // Calculate exponential backoff: baseDelay * (2 ^ attempt)
        let exponentialDelay = baseDelay * pow(2.0, Double(attempt))

        // Add random jitter between 0.0 and 0.5 seconds
        let jitter = Double.random(in: 0.0...0.5)

        return exponentialDelay + jitter
    }
}
