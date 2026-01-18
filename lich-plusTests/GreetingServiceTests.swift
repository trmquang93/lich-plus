//
//  GreetingServiceTests.swift
//  lich-plusTests
//
//  Tests for GreetingService backend integration
//  Verifies offline mode, backend configuration, and error handling
//

import XCTest
@testable import lich_plus

@MainActor
final class GreetingServiceTests: XCTestCase {

    var service: GreetingService!

    override func setUp() {
        super.setUp()
        service = GreetingService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    // MARK: - Backend Configuration Tests

    func testIsBackendConfigured_ReturnsFalseWhenURLIsNil() {
        // When backend URL is not configured (default state in tests)
        // isBackendConfigured should return false

        // Note: This test assumes no GREETING_API_URL environment variable is set
        // In production environment, this would be set
        let isConfigured = service.isBackendConfigured

        // In test environment, backend should not be configured by default
        XCTAssertFalse(isConfigured,
                       "Backend should not be configured in test environment without explicit setup")
    }

    // MARK: - Offline Greeting Generation Tests

    func testGenerateOfflineGreeting_ReturnsValidGreeting() {
        let request = GreetingRequest(
            recipientType: .parents,
            tone: .formal,
            occasion: .tet,
            year: 2026
        )

        let greeting = service.generateOfflineGreeting(for: request)

        XCTAssertFalse(greeting.isEmpty, "Offline greeting should not be empty")
        XCTAssertGreaterThan(greeting.count, 10, "Offline greeting should be meaningful length")
    }

    func testGenerateOfflineGreeting_ContainsYearSpecificContent() {
        let request = GreetingRequest(
            recipientType: .friends,
            tone: .casual,
            occasion: .tet,
            year: 2026
        )

        let greeting = service.generateOfflineGreeting(for: request)

        // 2026 = Bính Ngọ
        XCTAssertTrue(greeting.contains("Bính Ngọ") || greeting.contains("🐴 Ngọ"),
                      "Offline greeting should contain year-specific Can-Chi or zodiac")
    }

    func testGenerateOfflineGreeting_WorksForAllRecipientTypes() {
        let year = 2026

        for recipientType in RecipientType.allCases {
            let request = GreetingRequest(
                recipientType: recipientType,
                tone: .formal,
                occasion: .tet,
                year: year
            )

            let greeting = service.generateOfflineGreeting(for: request)

            XCTAssertFalse(greeting.isEmpty,
                           "Should generate offline greeting for \(recipientType.displayName)")
        }
    }

    // MARK: - Main API Tests (Offline Fallback)

    func testGenerateGreeting_UsesOfflineModeWhenBackendNotConfigured() async throws {
        // When backend is not configured, generateGreeting should fall back to offline mode
        let request = GreetingRequest(
            recipientType: .boss,
            tone: .formal,
            occasion: .tet,
            year: 2026
        )

        let greeting = try await service.generateGreeting(for: request)

        // Should return a valid greeting (from offline samples)
        XCTAssertFalse(greeting.isEmpty,
                       "Should return offline greeting when backend not configured")
        XCTAssertGreaterThan(greeting.count, 10,
                             "Offline fallback should return meaningful greeting")
    }

    func testGenerateGreeting_ReturnsConsistentFormatForAllTones() async throws {
        let recipientType = RecipientType.parents
        let year = 2026

        for tone in GreetingTone.allCases {
            let request = GreetingRequest(
                recipientType: recipientType,
                tone: tone,
                occasion: .tet,
                year: year
            )

            let greeting = try await service.generateGreeting(for: request)

            XCTAssertFalse(greeting.isEmpty,
                           "Should generate greeting for \(tone.displayName) tone")
        }
    }

    // MARK: - Request Model Tests

    func testGreetingAPIRequest_Codable() throws {
        let apiRequest = GreetingAPIRequest(
            recipientType: "parents",
            tone: "formal",
            occasion: "tet",
            recipientName: "Ba Mẹ",
            additionalInfo: nil,
            year: 2026
        )

        // Test encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(apiRequest)
        XCTAssertGreaterThan(data.count, 0, "Should encode to non-empty data")

        // Test decoding
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(GreetingAPIRequest.self, from: data)

        XCTAssertEqual(decoded.recipientType, apiRequest.recipientType)
        XCTAssertEqual(decoded.tone, apiRequest.tone)
        XCTAssertEqual(decoded.occasion, apiRequest.occasion)
        XCTAssertEqual(decoded.recipientName, apiRequest.recipientName)
        XCTAssertEqual(decoded.year, apiRequest.year)
    }

    func testGreetingAPIResponse_Codable_WithGreeting() throws {
        let jsonString = """
        {
            "greeting": "Chúc mừng năm mới!",
            "error": null
        }
        """
        let data = jsonString.data(using: .utf8)!

        let decoder = JSONDecoder()
        let response = try decoder.decode(GreetingAPIResponse.self, from: data)

        XCTAssertEqual(response.greeting, "Chúc mừng năm mới!")
        XCTAssertNil(response.error)
    }

    func testGreetingAPIResponse_Codable_WithError() throws {
        let jsonString = """
        {
            "greeting": null,
            "error": "Rate limit exceeded"
        }
        """
        let data = jsonString.data(using: .utf8)!

        let decoder = JSONDecoder()
        let response = try decoder.decode(GreetingAPIResponse.self, from: data)

        XCTAssertNil(response.greeting)
        XCTAssertEqual(response.error, "Rate limit exceeded")
    }

    // MARK: - Error Handling Tests

    func testGreetingServiceError_ErrorDescriptions() {
        // Test all error cases have proper localized descriptions
        let testError = NSError(domain: "test", code: 1, userInfo: nil)
        let networkError = GreetingServiceError.networkError(testError)
        XCTAssertNotNil(networkError.errorDescription)
        XCTAssertTrue(networkError.errorDescription?.contains("Lỗi mạng") ?? false)

        let invalidResponse = GreetingServiceError.invalidResponse
        XCTAssertNotNil(invalidResponse.errorDescription)
        XCTAssertEqual(invalidResponse.errorDescription, "Phản hồi không hợp lệ")

        let rateLimited = GreetingServiceError.rateLimited
        XCTAssertNotNil(rateLimited.errorDescription)
        XCTAssertEqual(rateLimited.errorDescription, "Quá nhiều yêu cầu, vui lòng thử lại sau")

        let serverError = GreetingServiceError.serverError("Server down")
        XCTAssertNotNil(serverError.errorDescription)
        XCTAssertTrue(serverError.errorDescription?.contains("Lỗi server") ?? false)
        XCTAssertTrue(serverError.errorDescription?.contains("Server down") ?? false)

        let unauthorized = GreetingServiceError.unauthorized
        XCTAssertNotNil(unauthorized.errorDescription)
        XCTAssertEqual(unauthorized.errorDescription, "Không có quyền truy cập")
    }

    // MARK: - Configuration Tests

    func testGreetingServiceConfig_DefaultValues() {
        // Verify default configuration values
        XCTAssertEqual(GreetingServiceConfig.requestTimeout, 30,
                       "Default timeout should be 30 seconds")
        XCTAssertTrue(GreetingServiceConfig.useOfflineFallback,
                      "Should use offline fallback by default")
    }
}
