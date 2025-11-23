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

/// The three-tier quality classification system for Vietnamese Phong Thủy
/// Based on traditional Vietnamese astrology, the 12 Zodiac Hours are classified into three tiers
enum ZodiacQuality: String, Equatable {
    case veryAuspicious = "Tứ Hộ Thần"      // 4 Very Auspicious (Trừ, Định, Nguy, Khai)
    case neutral = "Bán Cát Bán Hung"       // 2 Semi-auspicious/Neutral (Kiên, Chấp)
    case inauspicious = "Thần Hung"         // 6 Inauspicious (Mãn, Bình, Phá, Thành, Thu, Bế)
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

    /// Quality classification based on Vietnamese Phong Thủy three-tier system
    /// Tứ Hộ Thần (4 Very Auspicious): Trừ, Định, Nguy, Khai
    /// Bán Cát Bán Hung (2 Neutral): Kiên, Chấp
    /// Thần Hung (6 Inauspicious): Mãn, Bình, Phá, Thành, Thu, Bế
    var quality: ZodiacQuality {
        switch self {
        // Tứ Hộ Thần (4 Very Auspicious)
        case .tru, .dinh, .nguy, .khai:
            return .veryAuspicious
        // Bán Cát Bán Hung (2 Neutral)
        case .kien, .chap:
            return .neutral
        // Thần Hung (6 Inauspicious)
        case .man, .binh, .pha, .thanh, .thu, .be:
            return .inauspicious
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
struct DayQuality: Equatable {
    let zodiacHour: ZodiacHourType
    let dayCanChi: String
    let suitableActivities: [String]
    let tabooActivities: [String]
    let luckyDirection: String?
    let luckyColor: String?

    var isGoodDay: Bool {
        return zodiacHour.isAuspicious
    }

    var dayTypeDescription: String {
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
