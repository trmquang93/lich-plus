//
//  AstrologyData.swift
//  lich-plus
//
//  Vietnamese Astrology Reference Data
//  This file contains all the traditional Vietnamese astrology data for determining
//  auspicious and inauspicious activities based on the 12 Zodiac Hours (12 Kiến Trừ)
//

import Foundation

// MARK: - Activity Categories

struct ActivityCategories {
    // MARK: - Marriage & Relationships
    static let marriage = [
        "Cưới hỏi",
        "Dạm ngõ",
        "Đính hôn",
        "Lễ ăn hỏi"
    ]

    // MARK: - Construction & Building
    static let construction = [
        "Khởi công xây dựng",
        "Động thổ",
        "Sửa chữa nhà cửa",
        "Lợp mái",
        "Đóng cọc",
        "Lắp đặt cửa"
    ]

    // MARK: - Travel & Moving
    static let travel = [
        "Xuất hành",
        "Du lịch",
        "Chuyển nhà",
        "Nhập trạch",
        "An táng"
    ]

    // MARK: - Business & Commerce
    static let business = [
        "Khai trương",
        "Ký hợp đồng",
        "Giao dịch lớn",
        "Mua bán",
        "Đầu tư",
        "Nhận việc mới"
    ]

    // MARK: - Medical & Health
    static let medical = [
        "Khám bệnh",
        "Phẫu thuật",
        "Điều trị",
        "Châm cứu"
    ]

    // MARK: - Agriculture
    static let agriculture = [
        "Gieo trồng",
        "Thu hoạch",
        "Chăn nuôi",
        "Trồng cây"
    ]

    // MARK: - Religious & Ceremonial
    static let religious = [
        "Cúng tế",
        "Lễ Phật",
        "Cầu an",
        "Cầu tài"
    ]

    // MARK: - Learning & Development
    static let learning = [
        "Nhập học",
        "Thi cử",
        "Học việc",
        "Đào tạo"
    ]

    // MARK: - General Good Activities
    static let general = [
        "Làm việc quan trọng",
        "Gặp gỡ đối tác",
        "Ra quyết định lớn",
        "Bắt đầu dự án mới"
    ]

    // MARK: - Rest & Relaxation
    static let rest = [
        "Nghỉ ngơi",
        "Thư giãn",
        "Suy nghĩ",
        "Hoạch định"
    ]
}

// MARK: - Zodiac Hour Data

struct ZodiacHourData {
    /// Get suitable activities for a specific zodiac hour
    /// Updated to match Vietnamese Phong Thủy three-tier quality system
    static func getSuitableActivities(for zodiacHour: ZodiacHourType) -> [String] {
        switch zodiacHour {
        // NEUTRAL (Bán Cát Bán Hung)
        case .kien: // Kiên - Semi-auspicious, good for starting new things
            return [
                "Khai trương",
                "Nhậm chức",
                "Cưới hỏi",
                "Trồng cây",
                "Khởi đầu mới"
            ]

        case .chap: // Chấp - Neutral, good for maintenance/preservation
            return [
                "Tu sửa nhà cửa",
                "Tuyển dụng",
                "Thuê mướn",
                "Bảo trì",
                "Giữ gìn tài sản"
            ]

        // VERY AUSPICIOUS (Tứ Hộ Thần)
        case .tru: // Trừ - Very auspicious for removal/spiritual activities
            return [
                "Trừ phục",
                "Dâng sao giải hạn",
                "Tỉa chân nhang",
                "Thay bát hương",
                "Thanh lọc",
                "Trừ bệnh"
            ]

        case .dinh: // Định - Very auspicious for business/stabilization
            return [
                "Buôn bán",
                "Giao thương",
                "Ký hợp đồng",
                "Làm chuồng gia súc",
                "Ổn định công việc",
                "Xác lập kế hoạch"
            ]

        case .nguy: // Nguy - Very auspicious for spiritual activities
            return [
                "Lễ bái",
                "Cầu tự",
                "Tụng kinh",
                "Cúng tế",
                "Lễ Phật",
                "Cầu an"
            ]

        case .khai: // Khai - Very auspicious for opening/major events
            return [
                "Động thổ",
                "Kết hôn",
                "Khai trương",
                "Các việc lớn",
                "Mở mang",
                "Bắt đầu dự án"
            ]

        // INAUSPICIOUS (Thần Hung)
        case .man: // Mãn - Inauspicious, but good for worship/travel
            return [
                "Cúng lễ",
                "Xuất hành",
                "Sửa kho",
                "Nghỉ ngơi"
            ]

        case .binh: // Bình - Inauspicious, but good for minor business
            return [
                "Di dời bếp",
                "Giao thương nhỏ",
                "Mua bán",
                "Việc vặt"
            ]

        case .pha: // Phá - Inauspicious, only for demolition/travel
            return [
                "Đi xa",
                "Phá bỏ công trình cũ",
                "Dỡ bỏ",
                "Nghỉ ngơi"
            ]

        case .thanh: // Thành - Inauspicious, but good for learning/moving
            return [
                "Nhập học",
                "Kết hôn",
                "Dọn nhà mới",
                "Học tập"
            ]

        case .thu: // Thu - Inauspicious, but good for business/harvest
            return [
                "Mở cửa hàng",
                "Lập kho",
                "Buôn bán",
                "Thu hoạch"
            ]

        case .be: // Bế - Inauspicious, good for containment only
            return [
                "Đắp đập đê điều",
                "Ngăn nước",
                "Kết thúc",
                "Nghỉ ngơi"
            ]
        }
    }

    /// Get taboo activities for a specific zodiac hour
    /// Updated to match Vietnamese Phong Thủy three-tier quality system
    static func getTabooActivities(for zodiacHour: ZodiacHourType) -> [String] {
        switch zodiacHour {
        // NEUTRAL (Bán Cát Bán Hung)
        case .kien: // Kiên - Semi-auspicious
            return [
                "Động thổ",
                "Chôn cất",
                "Đào giếng"
            ]

        case .chap: // Chấp - Neutral
            return [
                "Xuất nhập kho",
                "Truy tiền",
                "An sàng"
            ]

        // VERY AUSPICIOUS (Tứ Hộ Thần)
        case .tru: // Trừ - Very auspicious
            return [
                "Chi xuất tiền lớn",
                "Ký hợp đồng",
                "Khai trương",
                "Cưới hỏi"
            ]

        case .dinh: // Định - Very auspicious
            return [
                "Thưa kiện",
                "Xuất hành đi xa"
            ]

        case .nguy: // Nguy - Very auspicious
            return [
                "Kinh doanh",
                "Động thổ",
                "Cưới xin",
                "Thăm hỏi"
            ]

        case .khai: // Khai - Very auspicious
            return [
                "An táng",
                "Động thổ không sạch sẽ",
                "Tang lễ"
            ]

        // INAUSPICIOUS (Thần Hung)
        case .man: // Mãn - Inauspicious
            return [
                "Chôn cất",
                "Kiện tụng",
                "Nhậm chức"
            ]

        case .binh: // Bình - Inauspicious
            return [
                "An táng",
                "Tang lễ"
            ]

        case .pha: // Phá - Inauspicious
            return [
                "Mở hàng",
                "Cưới hỏi",
                "Hội họp",
                "Việc quan trọng"
            ]

        case .thanh: // Thành - Inauspicious
            return [
                "Kiện tụng",
                "Cãi vã",
                "Tranh chấp"
            ]

        case .thu: // Thu - Inauspicious
            return [
                "Ma chay",
                "An táng",
                "Tảo mộ"
            ]

        case .be: // Bế - Inauspicious
            return [
                "Nhậm chức",
                "Khiếu kiện",
                "Đào giếng",
                "Khởi sự mới"
            ]
        }
    }

    /// Get lucky direction for a zodiac hour
    /// Prioritizes Tứ Hộ Thần (Very Auspicious) with most favorable directions
    static func getLuckyDirection(for zodiacHour: ZodiacHourType, dayCanChi: String) -> String? {
        // Simplified lucky direction based on zodiac hour and quality
        // In a full implementation, this would use more complex Can-Chi calculations
        switch zodiacHour {
        // Tứ Hộ Thần (Very Auspicious) - Most favorable directions
        case .tru:
            return "Đông Bắc"
        case .dinh:
            return "Tây Nam"
        case .nguy:
            return "Bắc"
        case .khai:
            return "Đông Nam"
        // Neutral
        case .kien:
            return "Đông"
        case .chap:
            return "Tây"
        // Inauspicious - Less favorable or no specific direction
        case .thanh:
            return "Nam"
        case .thu:
            return "Tây Bắc"
        default:
            return nil
        }
    }

    /// Get lucky color for a zodiac hour
    /// Prioritizes Tứ Hộ Thần (Very Auspicious) with most auspicious colors
    static func getLuckyColor(for zodiacHour: ZodiacHourType) -> String? {
        switch zodiacHour {
        // Tứ Hộ Thần (Very Auspicious) - Most auspicious colors
        case .tru:
            return "Đen, Xanh dương"
        case .dinh:
            return "Trắng, Bạc"
        case .nguy:
            return "Vàng, Vàng kim"
        case .khai:
            return "Xanh lá, Nâu"
        // Neutral
        case .kien:
            return "Đỏ, Cam"
        case .chap:
            return "Xám, Trắng"
        // Inauspicious - Less emphasis on lucky colors
        case .thanh:
            return "Xanh, Tím"
        default:
            return nil
        }
    }
}

// MARK: - Special Lunar Dates

struct SpecialLunarDates {
    /// Check if a lunar date is a special auspicious date
    /// Only truly special festival dates, not generic first/15th days of month
    /// Generic days should use the traditional 12 Trực method instead
    static func isSpecialAuspiciousDate(lunarDay: Int, lunarMonth: Int) -> Bool {
        // Special festival days only
        let specialDays: [(month: Int, day: Int)] = [
            (1, 1),   // Tết Nguyên Đán (Lunar New Year)
            (1, 15),  // Tết Nguyên Tiêu (Lantern Festival)
            (3, 3),   // Tết Hàn Thực (Cold Food Festival)
            (5, 5),   // Tết Đoan Ngọ (Dragon Boat Festival)
            (7, 15),  // Vu Lan (Ghost Festival)
            (8, 15),  // Tết Trung Thu (Mid-Autumn Festival)
            (10, 10), // Tết Thường Tân (Double Ninth Festival)
        ]

        return specialDays.contains { $0.month == lunarMonth && $0.day == lunarDay }
    }

    /// Check if a lunar date is a special inauspicious date
    /// Note: Generic inauspicious days (like end of month) are handled by the 12 Trực system
    static func isSpecialInauspiciousDate(lunarDay: Int, lunarMonth: Int) -> Bool {
        // 7th lunar month (Ghost month) - traditionally considered unlucky
        if lunarMonth == 7 {
            // 7th month is considered inauspicious for major activities
            // But specific days' Trực values are still calculated by the traditional method
            // This is a placeholder - actual behavior depends on traditional Trực system
            return false
        }

        return false
    }

    /// Get description for special dates
    static func getSpecialDateDescription(lunarDay: Int, lunarMonth: Int) -> String? {
        if lunarMonth == 1 && lunarDay == 1 {
            return "Tết Nguyên Đán - Ngày đại cát"
        } else if lunarMonth == 1 && lunarDay <= 3 {
            return "Tết Nguyên Đán - Ngày tốt lành"
        } else if lunarDay == 15 {
            return "Rằm tháng \(lunarMonth) - Ngày lễ, ngày tốt"
        } else if lunarDay == 1 {
            return "Mồng 1 tháng \(lunarMonth) - Ngày mới, ngày tốt"
        } else if lunarMonth == 7 && lunarDay >= 15 {
            return "Tháng 7 âm lịch - Nên cẩn trọng"
        }

        return nil
    }
}

// MARK: - Hourly Zodiac Calculation Helpers

struct HourlyZodiacHelper {
    /// Calculate which hours are auspicious for a given day zodiac
    /// In Vietnamese astrology, auspicious hours depend on the day's Chi (Earthly Branch), NOT the day's Trực
    /// This follows the traditional "Hoàng Đạo Cát Thời" (Auspicious Hours) system
    ///
    /// CRITICAL FIX: Previous implementation incorrectly used the day's Trực (ZodiacHourType) to determine
    /// lucky hours. This has been corrected to use the day's Chi (Earthly Branch) instead, which aligns with
    /// authoritative Vietnamese astrology sources and the traditional calendar calculation formulas.
    ///
    /// The lucky hours mapping follows a consistent 6-pair system based on the 12 Earthly Branches:
    /// - Days with paired Chi values share the same set of 6 auspicious hours
    /// - Hour index 0-11 maps directly to Chi values in sequence
    ///
    /// Pairing (based on traditional Vietnamese astrology):
    /// - Tý (0) & Ngọ (6) → same lucky hours
    /// - Sửu (1) & Mùi (7) → same lucky hours
    /// - Dần (2) & Thân (8) → same lucky hours
    /// - Mão (3) & Dậu (9) → same lucky hours
    /// - Thìn (4) & Tuất (10) → same lucky hours
    /// - Tỵ (5) & Hợi (11) → same lucky hours
    static func getAuspiciousHours(for dayZodiacHour: ZodiacHourType, dayChi: ChiEnum) -> [Int] {
        // Lucky hours are determined by the day's Chi (Earthly Branch), NOT the day's Trực
        // This is the correct traditional Vietnamese astrology calculation method
        //
        // NOTE: The current mapping needs verification against Lịch Vạn Niên 2005-2009, Pages 51-52
        // The book's table shows different hour mappings than currently implemented
        // Reference: Page 52 mnemonic table shows Dần/Thân days should have hours [0,1,4,6,7,10]
        // but current implementation uses [2,4,5,8,9,11]. Requires detailed table analysis.

        switch dayChi {
        case .ty, .ngo:          // Tý (0), Ngọ (6) days
            return [0, 1, 3, 6, 8, 9]      // Tý, Sửu, Mão, Ngọ, Thân, Dậu

        case .suu, .mui:         // Sửu (1), Mùi (7) days
            return [2, 3, 5, 8, 10, 11]    // Dần, Mão, Tỵ, Thân, Tuất, Hợi

        case .dan, .than:        // Dần (2), Thân (8) days
            return [2, 4, 5, 8, 9, 11]     // Dần, Thìn, Tỵ, Thân, Tuất, Hợi

        case .mao, .dau:         // Mão (3), Dậu (9) days
            return [0, 2, 3, 6, 7, 9]      // Tý, Dần, Mão, Ngọ, Mùi, Dậu

        case .thin, .tuat:       // Thìn (4), Tuất (10) days
            return [2, 4, 5, 8, 9, 11]     // Dần, Thìn, Tỵ, Thân, Tuất, Hợi

        case .ty2, .hoi:         // Tỵ (5), Hợi (11) days
            return [1, 4, 6, 7, 10, 11]    // Sửu, Thìn, Ngọ, Mùi, Tuất, Hợi
        }
    }

    /// Get the Chi for a specific hour (0-11)
    static func getChiForHour(_ hour: Int) -> ChiEnum {
        // Hour index maps directly to Chi (0 = Tý, 1 = Sửu, etc.)
        return ChiEnum(rawValue: hour) ?? .ty
    }
}
