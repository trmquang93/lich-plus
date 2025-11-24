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
/// Source: Book pages 153-157, Column C "Sao Tốt"
/// Expanded: Added common stars from Month 9 analysis
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

    // MARK: - Newly Added Stars (Phase 2A)
    case ngoHop = "Ngọ hợp"             // Horse Harmony - Good for cooperation, partnerships

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
        case .trucLinh, .thienThuy, .nhanChuyen, .ngoHop:
            return 1.0  // Moderate positive influence
        case .mannDucTinh, .nguyetKhong:
            return 0.5  // Minor positive influence
        }
    }
}

// MARK: - Extended Bad Stars (Sao Xấu - Beyond Lục Hắc Đạo)

/// Extended bad stars beyond the 6 Lục Hắc Đạo
/// Source: Book pages 153-157, Column B "Sao Xấu"
/// Expanded: Added common stars from Month 9 analysis (Phase 2A)
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

    // MARK: - Newly Added Stars (Phase 2A - from Month 9 analysis)
    case cauTran = "Câu trần"           // Hook of Dust - Bad for relationships
    case nguHu = "Ngũ hư"               // Five Empty - Loss, emptiness
    case tieuHongSa = "Tiểu hồng sa"    // Small Red Sand - Minor obstacles
    case tieuHao = "Tiểu hao"           // Small Consumption - Minor loss
    case huyenVu = "Huyền vũ"           // Dark Warrior - Danger, darkness
    case nguyetHu = "Nguyệt hư"         // Moon Empty - Emptiness
    case hoaLinh = "Hỏa linh"           // Fire Spirit - Different from Fire Star
    case cuuKhong = "Cửu không"         // Nine Empty - Major emptiness
    case nguyetYem = "Nguyệt yếm"       // Moon Sickness - Illness
    case loiCong = "Lôi công"           // Thunder Attack - Sudden danger

    /// Scoring weight for this bad star (negative values)
    var score: Double {
        switch self {
        case .thuTu, .cuuThoQuy:
            return -3.0  // Very severe (Death, Nine Earth Ghosts)
        case .lySao, .hoaTinh, .kiepSat, .diaPha, .cuuKhong:
            return -2.0  // Severe (Separation, Fire, Robbery, Nine Empty)
        case .daiHao, .kimThanThatSat, .thienCuong, .cauTran:
            return -1.5  // Significant negative (Great Loss, Hook of Dust)
        case .hoaTai, .thienHoa, .nguyetHoa, .hoaLinh, .huyenVu, .loiCong:
            return -1.0  // Fire/danger-related (Fire disasters, Dark Warrior, Thunder)
        case .hoangVu, .khongPhong, .bangTieu, .nguyetYem:
            return -1.0  // Moderate negative (Desolate, Empty Room, Moon Sickness)
        case .thoOn, .hoangSa, .phiMaSat, .nguQuy, .quaTu, .nguHu, .nguyetHu:
            return -0.5  // Minor negative (Five Empty, Moon Empty, etc.)
        case .tieuHongSa, .tieuHao:
            return -0.3  // Very minor negative (Small obstacles/loss)
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
