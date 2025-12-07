//
//  RecurrenceRuleContainer.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 07/12/25.
//

import Foundation

// MARK: - RecurrenceRuleContainer

/// A discriminated union for solar and lunar recurrence rules
///
/// This enum provides a unified interface for handling both solar (Gregorian)
/// and lunar calendar recurrence rules, allowing them to be serialized and
/// deserialized as a single Codable type.
enum RecurrenceRuleContainer: Codable {
    /// Solar calendar recurrence rule (Gregorian calendar)
    case solar(SerializableRecurrenceRule)

    /// Lunar calendar recurrence rule
    case lunar(SerializableLunarRecurrenceRule)

    /// No recurrence
    case none

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case type
        case rule
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "solar":
            let rule = try container.decode(SerializableRecurrenceRule.self, forKey: .rule)
            self = .solar(rule)
        case "lunar":
            let rule = try container.decode(SerializableLunarRecurrenceRule.self, forKey: .rule)
            self = .lunar(rule)
        case "none":
            self = .none
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown recurrence type: \(type)"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .solar(let rule):
            try container.encode("solar", forKey: .type)
            try container.encode(rule, forKey: .rule)
        case .lunar(let rule):
            try container.encode("lunar", forKey: .type)
            try container.encode(rule, forKey: .rule)
        case .none:
            try container.encode("none", forKey: .type)
        }
    }
}
