//
//  GreetingService.swift
//  lich-plus
//
//  Created by Claude on 17/01/26.
//

import Foundation

// MARK: - Greeting Service Error

enum GreetingServiceError: LocalizedError {
    case apiKeyMissing
    case networkError(Error)
    case invalidResponse
    case rateLimited

    var errorDescription: String? {
        switch self {
        case .apiKeyMissing:
            return "API key chưa được cấu hình"
        case .networkError(let error):
            return "Lỗi mạng: \(error.localizedDescription)"
        case .invalidResponse:
            return "Phản hồi không hợp lệ"
        case .rateLimited:
            return "Quá nhiều yêu cầu, vui lòng thử lại sau"
        }
    }
}

// MARK: - Greeting Service

/// Service for generating greeting messages using Claude API
class GreetingService {
    private let apiKey: String
    private let apiURL = URL(string: "https://api.anthropic.com/v1/messages")!
    private let modelID = "claude-3-5-haiku-20241022"

    // MARK: - Initialization

    init(apiKey: String? = nil) {
        if let apiKey = apiKey {
            self.apiKey = apiKey
        } else if let storedKey = NLPConfiguration.retrieveAPIKey() {
            self.apiKey = storedKey
        } else if let envKey = ProcessInfo.processInfo.environment["CLAUDE_API_KEY"] {
            self.apiKey = envKey
        } else {
            self.apiKey = ""
        }
    }

    // MARK: - Public Methods

    /// Check if API key is available
    var isAPIKeyConfigured: Bool {
        !apiKey.isEmpty
    }

    /// Generate a greeting message
    /// - Parameter request: The greeting request with recipient type, tone, etc.
    /// - Returns: Generated greeting text
    func generateGreeting(for request: GreetingRequest) async throws -> String {
        // If no API key, use sample greetings
        guard isAPIKeyConfigured else {
            return SampleGreetings.randomGreeting(for: request)
        }

        let systemPrompt = buildSystemPrompt(for: request)
        let userMessage = buildUserMessage(for: request)

        return try await callClaudeAPI(userMessage: userMessage, systemPrompt: systemPrompt)
    }

    /// Generate greeting using offline samples (fallback)
    func generateOfflineGreeting(for request: GreetingRequest) -> String {
        return SampleGreetings.randomGreeting(for: request)
    }

    // MARK: - Private Methods

    private func buildSystemPrompt(for request: GreetingRequest) -> String {
        let canChi = GreetingOccasion.canChi(for: request.year)
        let zodiac = GreetingOccasion.zodiacAnimal(for: request.year) ?? ""

        return """
        Bạn là chuyên gia viết lời chúc Tết Việt Nam. Hãy tạo lời chúc Tết năm \(canChi) (\(zodiac)) theo yêu cầu.

        Quy tắc:
        1. Viết bằng tiếng Việt, tự nhiên và chân thành
        2. Độ dài: 2-4 câu (khoảng 50-100 từ)
        3. Có thể dùng emoji phù hợp nếu phong cách thân mật/vui vẻ
        4. Nhắc đến năm \(canChi) hoặc con giáp \(zodiac) nếu phù hợp
        5. Phù hợp với mối quan hệ và phong cách được yêu cầu
        6. KHÔNG bao gồm tiêu đề hay định dạng markdown
        7. Chỉ trả về nội dung lời chúc, không giải thích gì thêm

        Các cụm từ Tết thường dùng:
        - An khang thịnh vượng
        - Vạn sự như ý
        - Phúc lộc đầy nhà
        - Mã đáo thành công (năm Ngọ)
        - Sức khỏe dồi dào
        - Gia đình hạnh phúc
        """
    }

    private func buildUserMessage(for request: GreetingRequest) -> String {
        var message = "Viết lời chúc Tết cho \(request.recipientType.displayName)"

        if let name = request.recipientName, !name.isEmpty {
            message += " (tên: \(name))"
        }

        message += " với phong cách \(request.tone.displayName.lowercased())."

        // Add specific guidance based on recipient type
        switch request.recipientType {
        case .grandparents:
            message += " Nhấn mạnh sức khỏe, trường thọ."
        case .parents:
            message += " Thể hiện lòng biết ơn và tình yêu thương."
        case .boss:
            message += " Chuyên nghiệp, chúc thành công trong công việc."
        case .colleagues:
            message += " Thân thiện, chúc công việc thuận lợi."
        case .teachers:
            message += " Kính trọng, cảm ơn sự dìu dắt."
        case .friends:
            message += " Thoải mái, có thể hài hước nếu phong cách cho phép."
        case .partner:
            message += " Ngọt ngào, thể hiện tình cảm."
        case .children:
            message += " Yêu thương, động viên học tập và trưởng thành."
        }

        return message
    }

    private func callClaudeAPI(userMessage: String, systemPrompt: String) async throws -> String {
        guard !apiKey.isEmpty else {
            throw GreetingServiceError.apiKeyMissing
        }

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")

        let payload = ClaudeAPIRequestPayload(
            model: modelID,
            max_tokens: 512,
            system: systemPrompt,
            messages: [
                ClaudeMessagePayload(role: "user", content: userMessage)
            ]
        )

        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GreetingServiceError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            let decodedResponse = try JSONDecoder().decode(ClaudeAPIResponsePayload.self, from: data)
            guard let textContent = decodedResponse.content.first?.text else {
                throw GreetingServiceError.invalidResponse
            }
            return textContent.trimmingCharacters(in: .whitespacesAndNewlines)

        case 429:
            throw GreetingServiceError.rateLimited

        case 401, 403:
            throw GreetingServiceError.apiKeyMissing

        default:
            throw GreetingServiceError.networkError(
                NSError(domain: "HTTP", code: httpResponse.statusCode, userInfo: nil)
            )
        }
    }
}

// MARK: - API Models

private struct ClaudeAPIRequestPayload: Codable {
    let model: String
    let max_tokens: Int
    let system: String
    let messages: [ClaudeMessagePayload]
}

private struct ClaudeMessagePayload: Codable {
    let role: String
    let content: String
}

private struct ClaudeAPIResponsePayload: Codable {
    let content: [ContentBlockPayload]
}

private struct ContentBlockPayload: Codable {
    let type: String
    let text: String
}
