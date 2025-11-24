//
//  StarModels.swift
//  lich-plus
//
//  Created by AI Assistant on 2025-11-24.
//  Traditional Vietnamese Astrology Star System
//  Source: Lịch Vạn Niên 2005-2009, Pages 153-154 (Month 9)
//

import Foundation

// MARK: - Good Stars (Sao Tốt)

/// Good stars that make days auspicious
/// Source: Book page 153, Column C "Sao Tốt"
enum GoodStar: String, CaseIterable {
    case thienAn = "Thiên ân"           // Heavenly Grace - Makes activities auspicious
    case satCong = "Sát công"           // Kill Work/Success - Good for completing tasks
    case trucLinh = "Trực linh"         // Direct Spirit - Favorable influence
    case thienThuy = "Thiên thụy"       // Heavenly Fate - Auspicious timing
    case nhanChuyen = "Nhân chuyển"     // Human Transfer - Good for moving/travel
    case thienQuan = "Thiên quan"       // Heavenly Official - Authority blessing
    case tamHopThienGiai = "Tam hợp Thiên giải"  // Three Harmony Heaven Release
    case nguyetKhong = "Nguyệt không"   // Moon Empty - Sometimes beneficial
    case thienDuc = "Thiên đức"         // Heavenly Virtue - All good activities
    case nguyetDuc = "Nguyệt đức"       // Moon Virtue - Good timing
    case mannDucTinh = "Mần đức tinh"   // Virtue Star - Charitable work

    /// Scoring weight for this good star
    var score: Double {
        switch self {
        case .thienAn:
            return 3.0  // Very powerful positive influence
        case .tamHopThienGiai:
            return 2.5  // Major positive factor
        case .thienQuan:
            return 2.0  // Strong authority blessing
        case .satCong:
            return 1.5  // Good for work completion
        case .thienDuc, .nguyetDuc:
            return 1.5  // Virtue blessings
        case .trucLinh, .thienThuy, .nhanChuyen:
            return 1.0  // Moderate positive influence
        case .mannDucTinh, .nguyetKhong:
            return 0.5  // Minor positive influence
        }
    }
}

// MARK: - Extended Bad Stars (Sao Xấu - Beyond Lục Hắc Đạo)

/// Extended bad stars beyond the 6 Lục Hắc Đạo
/// Source: Book page 153, Column B "Sao Xấu"
enum ExtendedBadStar: String, CaseIterable {
    case lySao = "Ly sào"               // Separation - Bad for relationships, travel
    case hoaTinh = "Hỏa tinh"           // Fire Star - Dangerous
    case cuuThoQuy = "Cửu thổ quỷ"      // Nine Earth Ghosts - Very inauspicious
    case diaPha = "Địa phá"             // Earth Break - Bad for construction
    case hoangVu = "Hoang vu"           // Desolate - Unfavorable
    case khongPhong = "Không phòng"     // Empty Room - Bad for weddings
    case bangTieu = "Băng tiêu"         // Ice Melt - Unstable
    case thuTu = "Thụ tử"               // Death - Very bad
    case kiepSat = "Kiếp sát"           // Robbery Kill - Danger
    case thienCuong = "Thiên cương"     // Heaven Steel - Obstacles
    case hoaTai = "Hỏa tai"             // Fire Disaster
    case thienHoa = "Thiên hỏa"         // Heaven Fire
    case thoOn = "Thổ ôn"               // Earth Warmth
    case hoangSa = "Hoang sa"           // Yellow Sand
    case phiMaSat = "Phi ma sát"        // Flying Horse Kill
    case nguQuy = "Ngũ quỷ"             // Five Ghosts
    case quaTu = "Quả tú"               // Widow
    case daiHao = "Đại hao"             // Great Consumption - Loss of wealth
    case kimThanThatSat = "Kim thần thất sát"  // Metal God Seven Kills
    case nguyetHoa = "Nguyệt hoạ"       // Moon Fire

    /// Scoring weight for this bad star (negative values)
    var score: Double {
        switch self {
        case .thuTu, .cuuThoQuy:
            return -3.0  // Very severe
        case .lySao, .hoaTinh, .kiepSat, .diaPha:
            return -2.0  // Severe
        case .daiHao, .kimThanThatSat, .thienCuang:
            return -1.5  // Significant negative
        case .hoaTai, .thienHoa, .nguyetHoa:
            return -1.0  // Fire-related dangers
        case .hoangVu, .khongPhong, .bangTieu:
            return -1.0  // Moderate negative
        case .thoOn, .hoangSa, .phiMaSat, .nguQuy, .quaTu:
            return -0.5  // Minor negative
        }
    }
}

// MARK: - Star Data Structure

/// Star configuration for a specific day (Can-Chi combination)
struct DayStarData: Equatable {
    let canChi: String          // e.g., "Giáp Tý"
    let goodStars: [GoodStar]
    let badStars: [ExtendedBadStar]

    /// Calculate the net score from stars
    var netScore: Double {
        let goodScore = goodStars.reduce(0.0) { $0 + $1.score }
        let badScore = badStars.reduce(0.0) { $0 + $1.score }
        return goodScore + badScore  // badScore is negative
    }
}

// MARK: - Month Star Data

/// Complete star data for a lunar month
struct MonthStarData {
    let month: Int              // 1-12 lunar month
    let dayData: [String: DayStarData]  // Can-Chi -> Star data

    /// Look up star data for a specific Can-Chi combination
    func starsForDay(canChi: String) -> DayStarData? {
        return dayData[canChi]
    }
}
