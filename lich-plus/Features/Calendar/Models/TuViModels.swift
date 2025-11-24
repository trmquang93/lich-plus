//
//  TuViModels.swift
//  lich-plus
//
//  Vietnamese Astrology Models - Tử Vi (Tử Huyền) System
//  This file defines the core data structures for Vietnamese astrology calculations
//  based on the traditional Can-Chi (Heavenly Stems & Earthly Branches) system
//

import Foundation

// MARK: - Thiên Can (Heavenly Stems)

/// The 10 Heavenly Stems (Thiên Can) used in Vietnamese astrology
/// Each Can represents one of the Five Elements (Ngũ Hành) in either Yin or Yang form
/// Ordered according to the Vietnamese calendar standard starting with Canh (Metal)
enum CanEnum: Int, CaseIterable, Equatable {
    case canh = 0   // Canh - Metal Yang
    case tan = 1    // Tân - Metal Yin
    case nham = 2   // Nhâm - Water Yang
    case quy = 3    // Quý - Water Yin
    case giap = 4   // Giáp - Wood Yang
    case at = 5     // Ất - Wood Yin
    case binh = 6   // Bính - Fire Yang
    case dinh = 7   // Đinh - Fire Yin
    case mau = 8    // Mậu - Earth Yang
    case ky = 9     // Kỷ - Earth Yin

    var vietnameseName: String {
        switch self {
        case .giap: return "Giáp"
        case .at: return "Ất"
        case .binh: return "Bính"
        case .dinh: return "Đinh"
        case .mau: return "Mậu"
        case .ky: return "Kỷ"
        case .canh: return "Canh"
        case .tan: return "Tân"
        case .nham: return "Nhâm"
        case .quy: return "Quý"
        }
    }

    var element: String {
        switch self {
        case .giap, .at: return "Mộc" // Wood
        case .binh, .dinh: return "Hỏa" // Fire
        case .mau, .ky: return "Thổ" // Earth
        case .canh, .tan: return "Kim" // Metal
        case .nham, .quy: return "Thủy" // Water
        }
    }

    var isYang: Bool {
        return rawValue % 2 == 0
    }
}

// MARK: - Địa Chi (Earthly Branches)

/// The 12 Earthly Branches (Địa Chi) used in Vietnamese astrology
/// Each Chi represents a zodiac animal and corresponds to a 2-hour period
enum ChiEnum: Int, CaseIterable, Equatable {
    case ty = 0     // Tý - Rat (23:00-01:00)
    case suu = 1    // Sửu - Ox (01:00-03:00)
    case dan = 2    // Dần - Tiger (03:00-05:00)
    case mao = 3    // Mão - Rabbit (05:00-07:00)
    case thin = 4   // Thìn - Dragon (07:00-09:00)
    case ty2 = 5    // Tỵ - Snake (09:00-11:00)
    case ngo = 6    // Ngọ - Horse (11:00-13:00)
    case mui = 7    // Mùi - Goat (13:00-15:00)
    case than = 8   // Thân - Monkey (15:00-17:00)
    case dau = 9    // Dậu - Rooster (17:00-19:00)
    case tuat = 10  // Tuất - Dog (19:00-21:00)
    case hoi = 11   // Hợi - Pig (21:00-23:00)

    var vietnameseName: String {
        switch self {
        case .ty: return "Tý"
        case .suu: return "Sửu"
        case .dan: return "Dần"
        case .mao: return "Mão"
        case .thin: return "Thìn"
        case .ty2: return "Tỵ"
        case .ngo: return "Ngọ"
        case .mui: return "Mùi"
        case .than: return "Thân"
        case .dau: return "Dậu"
        case .tuat: return "Tuất"
        case .hoi: return "Hợi"
        }
    }

    var zodiacAnimal: String {
        switch self {
        case .ty: return "Chuột" // Rat
        case .suu: return "Trâu" // Ox
        case .dan: return "Cọp" // Tiger
        case .mao: return "Mèo" // Cat (Vietnamese uses Cat instead of Rabbit)
        case .thin: return "Rồng" // Dragon
        case .ty2: return "Rắn" // Snake
        case .ngo: return "Ngựa" // Horse
        case .mui: return "Dê" // Goat
        case .than: return "Khỉ" // Monkey
        case .dau: return "Gà" // Rooster
        case .tuat: return "Chó" // Dog
        case .hoi: return "Heo" // Pig
        }
    }

    /// Get the hour range (0-23) for this Chi
    var hourRange: (start: Int, end: Int) {
        switch self {
        case .ty: return (23, 1) // Special case: crosses midnight
        case .suu: return (1, 3)
        case .dan: return (3, 5)
        case .mao: return (5, 7)
        case .thin: return (7, 9)
        case .ty2: return (9, 11)
        case .ngo: return (11, 13)
        case .mui: return (13, 15)
        case .than: return (15, 17)
        case .dau: return (17, 19)
        case .tuat: return (19, 21)
        case .hoi: return (21, 23)
        }
    }
}

// MARK: - Zodiac Quality Classification

/// The four-tier quality classification system for Vietnamese Phong Thủy
/// Based on traditional Lịch Vạn Niên (Perpetual Calendar) classification
/// Reference: Lịch Vạn Niên 2005-2009, Pages 48-50
///
/// Traditional Classification:
/// - Hoàng Đạo (Good): Trừ, Nguy, Định, Chấp (4 types)
/// - Moderate (Can use): Thành, Khai (2 types)
/// - Hắc Đạo (Bad): Kiến, Mãn, Bình, Thu (4 types)
/// - Very Bad (Avoid): Phá, Bế (2 types)
enum ZodiacQuality: String, Equatable {
    case veryAuspicious = "Hoàng Đạo"           // Good (Trừ, Định, Nguy, Chấp)
    case neutral = "Khả Dụng"                   // Moderate - Can use (Thành, Khai)
    case inauspicious = "Hắc Đạo"               // Bad (Kiến, Mãn, Bình, Thu)
    case severelyInauspicious = "Rất Hung"      // Very Bad - Avoid (Phá, Bế)
}

// MARK: - Zodiac Hour Type (12 Kiến Trừ)

/// The 12 Zodiac Hour Types (12 Kiến Trừ) in Vietnamese astrology
/// These determine whether a period is auspicious (Hoàng Đạo) or inauspicious (Hắc Đạo)
enum ZodiacHourType: Int, CaseIterable, Equatable {
    case kien = 0   // Kiến - Establish
    case tru = 1    // Trừ - Remove
    case man = 2    // Mãn - Full
    case binh = 3   // Bình - Balance
    case dinh = 4   // Định - Stabilize
    case chap = 5   // Chấp - Grasp
    case pha = 6    // Phá - Break
    case nguy = 7   // Nguy - Danger
    case thanh = 8  // Thành - Success
    case thu = 9    // Thu - Collect
    case khai = 10  // Khai - Open
    case be = 11    // Bế - Close

    var vietnameseName: String {
        switch self {
        case .kien: return "Kiến"
        case .tru: return "Trừ"
        case .man: return "Mãn"
        case .binh: return "Bình"
        case .dinh: return "Định"
        case .chap: return "Chấp"
        case .pha: return "Phá"
        case .nguy: return "Nguy"
        case .thanh: return "Thành"
        case .thu: return "Thu"
        case .khai: return "Khai"
        case .be: return "Bế"
        }
    }

    /// Quality classification based on traditional Lịch Vạn Niên (Perpetual Calendar)
    /// Reference: Lịch Vạn Niên 2005-2009, Page 48
    ///
    /// Traditional Four-Tier Classification:
    /// - Hoàng Đạo (Good): Trừ, Định, Nguy, Chấp (4 types)
    /// - Moderate (Can use): Thành, Khai (2 types)
    /// - Hắc Đạo (Bad): Kiến, Mãn, Bình, Thu (4 types)
    /// - Very Bad (Avoid): Phá, Bế (2 types)
    var quality: ZodiacQuality {
        switch self {
        // Hoàng Đạo (Good) - 4 types
        case .tru, .dinh, .nguy, .chap:
            return .veryAuspicious
        // Moderate (Can use) - 2 types
        case .thanh, .khai:
            return .neutral
        // Hắc Đạo (Bad) - 4 types
        case .kien, .man, .binh, .thu:
            return .inauspicious
        // Very Bad (Avoid) - 2 types
        case .pha, .be:
            return .severelyInauspicious
        }
    }

    /// Whether this is an auspicious zodiac hour (for backward compatibility)
    /// Returns true for very auspicious hours only
    var isAuspicious: Bool {
        return quality == .veryAuspicious
    }

    var displayName: String {
        return "\(vietnameseName) (\(isAuspicious ? "Hoàng Đạo" : "Hắc Đạo"))"
    }

    var fullDescription: String {
        switch self {
        case .kien:
            return "Kiên - Ngày khởi đầu mới mẻ. Tốt cho: khai trương, nhậm chức, cưới hỏi, trồng cây. Xấu cho: động thổ, chôn cất, đào giếng."
        case .tru:
            return "Trừ - Bớt đi những điều không tốt. Tốt cho: trừ phục, dâng sao giải hạn, tỉa chân nhang, thay bát hương. Tránh: chi xuất tiền lớn, ký hợp đồng, khai trương, cưới hỏi."
        case .man:
            return "Mãn - Giai đoạn phát triển sung mãn. Tốt cho: cúng lễ, xuất hành, sửa kho. Xấu cho: chôn cất, kiện tụng, nhậm chức."
        case .binh:
            return "Bình - Lấy lại bình hòa. Mọi việc đều tốt. Tốt nhất cho: di dời bếp, giao thương, mua bán."
        case .dinh:
            return "Định - Ổn định, xác lập, ký kết. Tốt cho: buôn bán, giao thương, làm chuồng gia súc. Tránh: thưa kiện, xuất hành đi xa."
        case .chap:
            return "Chấp - Giữ gìn, bảo toàn. Tốt cho: tu sửa, tuyển dụng, thuê mướn. Tránh: xuất nhập kho, truy tiền, an sàng."
        case .pha:
            return "Phá - Phá bỏ những thứ lỗi thời. Tốt cho: đi xa, phá bỏ công trình cũ. Xấu cho: mở hàng, cưới hỏi, hội họp."
        case .nguy:
            return "Nguy - Giai đoạn nguy hiểm suy thoái. Nên làm: lễ bái, cầu tự, tụng kinh. Xấu cho: kinh doanh, động thổ, cưới xin, thăm hỏi."
        case .thanh:
            return "Thành - Cái mới được khởi đầu và hình thành. Tốt cho: nhập học, kết hôn, dọn nhà mới. Tránh: kiện tụng, cãi vã, tranh chấp."
        case .thu:
            return "Thu (Thâu) - Gặt hái thành công, thu về kết quả. Tốt cho: mở cửa hàng, lập kho, buôn bán. Tránh: ma chay, an táng, tảo mộ."
        case .khai:
            return "Khai - Mọi vật sau quy tàng thì thuận lợi, hanh thông bắt đầu mở ra. Tốt cho: động thổ, kết hôn, các việc lớn, nhiều cát lành. Kiêng: an táng, động thổ không sạch sẽ."
        case .be:
            return "Bế - Mọi việc trở lại khó khăn, gặp gian nan, trở ngại. Nên làm: đắp đập đê điều, ngăn nước. Xấu cho: nhậm chức, khiếu kiện, đào giếng."
        }
    }
}

// MARK: - Day Quality

/// Represents the astrological quality of a specific day
/// Combines multiple Vietnamese astrology systems (12 Trực, Lục Hắc Đạo, Star System, etc.)
struct DayQuality: Equatable {
    let zodiacHour: ZodiacHourType
    let dayCanChi: String
    let unluckyDayType: LucHacDaoCalculator.UnluckyDayType?
    let suitableActivities: [String]
    let tabooActivities: [String]
    let luckyDirection: String?
    let luckyColor: String?

    // MARK: - Star System (NEW - Phase 2 Enhancement)
    /// Good stars present on this day (Thiên ân, Sát công, etc.)
    let goodStars: [GoodStar]?

    /// Extended bad stars present on this day (Ly sào, Hỏa tinh, etc.)
    let badStars: [ExtendedBadStar]?

    /// Net score contribution from stars (positive from good stars, negative from bad stars)
    var starScore: Double {
        let goodScore = goodStars?.reduce(0.0) { $0 + $1.score } ?? 0.0
        let badScore = badStars?.reduce(0.0) { $0 + $1.score } ?? 0.0
        return goodScore + badScore
    }

    /// Check if star data is available for this day
    var hasStarData: Bool {
        return goodStars != nil || badStars != nil
    }

    var isGoodDay: Bool {
        // If an unlucky day, it's not a good day
        if unluckyDayType != nil {
            return false
        }
        return zodiacHour.isAuspicious
    }

    /// Final composite day quality considering all systems
    /// Uses a weighted scoring system calibrated against xemngay.com and traditional Lịch Vạn Niên
    /// Reference: Lịch Vạn Niên 2005-2009, Pages 48-50, 153+
    /// Validation: xemngay.com ratings (format: https://xemngay.com/Default.aspx?blog=xngay&d=DDMMYYYY)
    ///
    /// Scoring Philosophy:
    /// - Traditional classification provides BASE quality (Hoàng Đạo vs Hắc Đạo)
    /// - Modern practice shows some Hắc Đạo days can be neutral without unlucky stars
    /// - Good stars (Thiên ân, Sát công) can elevate Hắc Đạo days to excellent
    /// - Bad stars (Ly sào, Hỏa tinh) can downgrade Hoàng Đạo days to neutral
    /// - Adjusted weights to match xemngay.com composite ratings
    ///
    /// Complete Formula:
    /// Final Score = BASE (12 Trực) + UNLUCKY PENALTY (Lục Hắc Đạo) + STAR BONUS/PENALTY (Good/Bad Stars)
    ///
    /// Calibrated scoring weights:
    /// - Hoàng Đạo (Good): Trừ, Định, Nguy, Chấp → +2.0
    /// - Moderate: Thành, Khai → -0.3
    /// - Hắc Đạo (Bad): Kiến, Mãn, Bình, Thu → 0.0 (neutral base - allows stars to determine quality)
    /// - Very Bad: Phá, Bế → -3.0
    /// - Good Stars: Thiên ân (+3.0), Sát công (+1.5), etc.
    /// - Bad Stars: Ly sào (-2.0), Hỏa tinh (-2.0), etc.
    var finalQuality: DayType {
        // Calculate base score from Trực (zodiac hour quality)
        var score: Double = 0

        // STEP 1: Calibrated scoring based on traditional classification + xemngay.com validation
        switch zodiacHour {
        // Hoàng Đạo (Good) - 4 types: Trừ, Định, Nguy, Chấp
        // xemngay confirms these as good days (e.g., Dec 1 Chấp = [5/5] perfect)
        case .tru, .dinh, .nguy, .chap:
            score = 2.0
        // Moderate (Can use) - 2 types: Thành, Khai
        // Traditionally moderate, slightly negative without other factors
        case .thanh, .khai:
            score = -0.3
        // Hắc Đạo (Bad) - 4 types: Kiến, Mãn, Bình, Thu
        // Traditional: bad, but xemngay shows they can be neutral/slightly good ([3]/[2.5])
        // when no unlucky stars present (e.g., Nov 3 Mãn = [3], Dec 12 Bình = [2.5])
        case .kien, .man, .binh, .thu:
            score = 0.0  // Neutral base score - allows good/neutral based on other factors
        // Very Bad (Avoid) - 2 types: Phá, Bế
        // xemngay confirms these as very bad (Dec 8 Bế = [0.5], Dec 15 Phá = [1])
        case .pha, .be:
            score = -3.0
        }

        // STEP 2: Check for unlucky days (Lục Hắc Đạo) and apply penalties
        let hasUnluckyDay = unluckyDayType != nil
        let unluckySeverity = unluckyDayType?.severity ?? 0

        if hasUnluckyDay {
            let severityPenalty: Double
            switch unluckySeverity {
            case 5: severityPenalty = -4.0      // Chu Tước - most severe
            case 4: severityPenalty = -2.5      // Thiên Lao, Thiên Hình
            case 3: severityPenalty = -2.0      // Bạch Hổ, Câu Trần
            case 2: severityPenalty = -1.5      // Nguyên Vũ - least severe
            default: severityPenalty = -2.5
            }
            score += severityPenalty
        }

        // STEP 3: Add star system contribution (NEW - Phase 2 Enhancement)
        // This is the key to reaching 100% accuracy with xemngay.com
        score += starScore

        // Special handling: severe unlucky days (severity >= 4) override good Trực
        if hasUnluckyDay && unluckySeverity >= 4 && score < 1.0 {
            return .bad  // Thiên Lao, Chu Tước make days bad
        }

        // Map final score to day type using traditional thresholds:
        // - score >= 1.0: good (Hoàng Đạo days, or Hắc Đạo with strong good stars)
        // - score >= -1.0: neutral (Moderate Trực, or mixed star influences)
        // - score < -1.0: bad (Hắc Đạo with unlucky days, or Very Bad Trực, or multiple bad stars)
        if score >= 1.0 {
            return .good
        } else if score >= -1.0 {
            return .neutral
        } else {
            return .bad
        }
    }

    var dayTypeDescription: String {
        if let unluckyDay = unluckyDayType {
            return unluckyDay.description
        }
        return zodiacHour.fullDescription
    }
}

// MARK: - Hourly Zodiac

/// Represents the zodiac quality for a specific hour period of the day
struct HourlyZodiac: Identifiable, Equatable {
    let id = UUID()
    let hour: Int // 0-11 for the 12 two-hour periods
    let chi: ChiEnum
    let zodiacHour: ZodiacHourType
    let isAuspicious: Bool
    let suitableActivities: [String]

    var timeRange: String {
        let range = chi.hourRange
        if chi == .ty {
            return "23:00 - 01:00"
        }
        return String(format: "%02d:00 - %02d:00", range.start, range.end)
    }

    var displayName: String {
        return "\(chi.vietnameseName) (\(zodiacHour.vietnameseName))"
    }
}

// MARK: - Can-Chi Pair

/// Represents a Can-Chi pair (e.g., "Giáp Tý", "Ất Sửu")
struct CanChiPair: Equatable {
    let can: CanEnum
    let chi: ChiEnum

    var displayName: String {
        return "\(can.vietnameseName) \(chi.vietnameseName)"
    }

    var fullDescription: String {
        return "\(can.vietnameseName) \(chi.vietnameseName) - \(can.element) \(chi.zodiacAnimal)"
    }
}
