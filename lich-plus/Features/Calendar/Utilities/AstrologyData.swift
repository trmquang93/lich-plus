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
    static func isSpecialAuspiciousDate(lunarDay: Int, lunarMonth: Int) -> Bool {
        // Tết (Lunar New Year) - First 3 days
        if lunarMonth == 1 && lunarDay <= 3 {
            return true
        }

        // Mid-month (Full moon days)
        if lunarDay == 15 {
            return true
        }

        // First day of month
        if lunarDay == 1 {
            return true
        }

        // Special festival days
        let specialDays: [(month: Int, day: Int)] = [
            (1, 1),   // Tết Nguyên Đán
            (1, 15),  // Tết Nguyên Tiêu
            (3, 3),   // Tết Hàn Thực
            (5, 5),   // Tết Đoan Ngọ
            (7, 15),  // Vu Lan
            (8, 15),  // Tết Trung Thu
            (10, 10), // Tết Thường Tân
        ]

        return specialDays.contains { $0.month == lunarMonth && $0.day == lunarDay }
    }

    /// Check if a lunar date is a special inauspicious date
    static func isSpecialInauspiciousDate(lunarDay: Int, lunarMonth: Int) -> Bool {
        // Last days of month (often considered less auspicious)
        if lunarDay >= 29 {
            return true
        }

        // 7th lunar month (Ghost month) - days 1, 15, and end of month
        if lunarMonth == 7 && (lunarDay == 1 || lunarDay == 15 || lunarDay >= 28) {
            return true
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
    /// In Vietnamese astrology, auspicious hours depend on the day's Trực (Zodiac Hour Type)
    /// This follows the traditional "Hoàng Đạo Cát Thời" (Auspicious Hours) system
    static func getAuspiciousHours(for dayZodiacHour: ZodiacHourType, dayChi: ChiEnum) -> [Int] {
        // The auspicious hours are determined by the day's Trực (ZodiacHourType)
        // Each of the 12 Trực types has specific auspicious hours throughout the day

        let auspiciousHours: [Int]
        switch dayZodiacHour {
        // VERY AUSPICIOUS (Tứ Hộ Thần)
        case .tru:  // Trừ - Very auspicious for spiritual/removal activities
            auspiciousHours = [1, 4, 6, 7, 10, 11]  // Sửu, Thìn, Ngọ, Mùi, Tuất, Hợi
        case .dinh:  // Định - Very auspicious for business/stabilization
            auspiciousHours = [0, 2, 5, 6, 8, 11]  // Tý, Dần, Tỵ, Ngọ, Thân, Hợi
        case .nguy:  // Nguy - Very auspicious for spiritual activities
            auspiciousHours = [1, 3, 4, 7, 9, 10]  // Sửu, Mão, Thìn, Mùi, Dậu, Tuất
        case .khai:  // Khai - Very auspicious for opening/major events
            auspiciousHours = [0, 2, 3, 6, 7, 9]   // Tý, Dần, Mão, Ngọ, Mùi, Dậu

        // NEUTRAL (Bán Cát Bán Hung)
        case .kien:  // Kiên - Semi-auspicious, good for starting things
            auspiciousHours = [1, 2, 4, 6, 10, 11] // Sửu, Dần, Thìn, Ngọ, Tuất, Hợi
        case .chap:  // Chấp - Neutral, good for maintenance
            auspiciousHours = [0, 3, 5, 7, 8, 9]   // Tý, Mão, Tỵ, Mùi, Thân, Dậu

        // INAUSPICIOUS (Thần Hung) - Fewer auspicious hours
        case .pha:  // Phá - Inauspicious, limited auspicious hours
            auspiciousHours = [2, 5, 8, 11]        // Dần, Tỵ, Thân, Hợi
        case .be:   // Bế - Inauspicious, limited auspicious hours
            auspiciousHours = [1, 4, 7, 10]        // Sửu, Thìn, Mùi, Tuất
        case .man:  // Mãn - Inauspicious, some auspicious hours
            auspiciousHours = [0, 3, 6, 9]         // Tý, Mão, Ngọ, Dậu
        case .binh: // Bình - Inauspicious, limited auspicious hours
            auspiciousHours = [2, 4, 6, 8, 10]     // Dần, Thìn, Ngọ, Thân, Tuất
        case .thanh: // Thành - Inauspicious, limited auspicious hours
            auspiciousHours = [1, 3, 5, 7, 9, 11]  // Sửu, Mão, Tỵ, Mùi, Dậu, Hợi
        case .thu:  // Thu - Inauspicious, some auspicious hours
            auspiciousHours = [0, 4, 8, 11]        // Tý, Thìn, Thân, Hợi
        }

        return auspiciousHours
    }

    /// Get the Chi for a specific hour (0-11)
    static func getChiForHour(_ hour: Int) -> ChiEnum {
        // Hour index maps directly to Chi (0 = Tý, 1 = Sửu, etc.)
        return ChiEnum(rawValue: hour) ?? .ty
    }
}
