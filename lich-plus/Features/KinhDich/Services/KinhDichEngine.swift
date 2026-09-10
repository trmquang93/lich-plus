//
//  KinhDichEngine.swift
//  lich-plus
//
//  Offline three-coin divination (gieo 3 đồng). Entertainment / tradition only.
//

import Foundation

enum KinhDichLineValue: Int, CaseIterable {
    case oldYin = 6
    case youngYang = 7
    case youngYin = 8
    case oldYang = 9

    var isYang: Bool { rawValue == 7 || rawValue == 9 }
    var isChanging: Bool { rawValue == 6 || rawValue == 9 }
}

struct KinhDichReading: Equatable {
    let lines: [KinhDichLineValue]
    let hexagram: Hexagram
    let changingLineIndices: [Int]

    var summary: String { hexagram.summary }

    var changingNote: String? {
        guard !changingLineIndices.isEmpty else { return nil }
        return String(localized: "Some lines are changing — treat this as a hint to stay flexible, not a fixed fate.")
    }
}

enum KinhDichEngine {
    /// Simulates one three-coin toss (2 = heads/yang, 3 = tails/yin per coin).
    static func tossCoins(rng: inout some RandomNumberGenerator) -> KinhDichLineValue {
        let sum = (0..<3).map { _ in rng.next() ? 2 : 3 }.reduce(0, +)
        return KinhDichLineValue(rawValue: sum) ?? .youngYin
    }

    /// Builds a reading from six coin tosses (bottom line first).
    static func reading(from lines: [KinhDichLineValue]) -> KinhDichReading? {
        guard lines.count == 6 else { return nil }
        let pattern = lines.map { $0.isYang ? "1" : "0" }.joined()
        guard let hexagram = HexagramLibrary.hexagram(forPattern: pattern) else { return nil }
        let changing = lines.enumerated().compactMap { index, line in
            line.isChanging ? index : nil
        }
        return KinhDichReading(lines: lines, hexagram: hexagram, changingLineIndices: changing)
    }

    static func randomReading(rng: inout some RandomNumberGenerator = SystemRandomNumberGenerator()) -> KinhDichReading {
        let lines = (0..<6).map { _ in tossCoins(rng: &rng) }
        return reading(from: lines)!
    }
}

struct Hexagram: Equatable, Identifiable {
    let id: Int
    let pattern: String
    let name: String
    let summary: String
}
