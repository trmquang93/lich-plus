//
//  ActivityPurpose.swift
//  lich-plus
//
//  Purposes for xem ngày cho việc (day verdict by activity).
//

import Foundation

/// A traditional activity users may want a day verdict for.
enum ActivityPurpose: String, CaseIterable, Identifiable, Sendable {
    case wedding
    case opening
    case groundbreaking
    case travel
    case contract
    case ancestorWorship

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .wedding: return String(localized: "Wedding")
        case .opening: return String(localized: "Grand Opening")
        case .groundbreaking: return String(localized: "Groundbreaking")
        case .travel: return String(localized: "Travel")
        case .contract: return String(localized: "Signing Contract")
        case .ancestorWorship: return String(localized: "Ancestor Worship")
        }
    }

    var iconName: String {
        switch self {
        case .wedding: return "heart.fill"
        case .opening: return "storefront.fill"
        case .groundbreaking: return "hammer.fill"
        case .travel: return "airplane"
        case .contract: return "doc.text.fill"
        case .ancestorWorship: return "flame.fill"
        }
    }

    /// Keywords matched against 12 Trực suitable/taboo activity lists.
    var activityKeywords: [String] {
        switch self {
        case .wedding:
            return ["Cưới", "hôn", "hỏi", "Kết hôn", "Đính hôn"]
        case .opening:
            return ["Khai trương", "Mở cửa", "mở hàng", "Mở mang"]
        case .groundbreaking:
            return ["Động thổ", "Khởi công", "xây dựng", "Lợp mái"]
        case .travel:
            return ["Xuất hành", "Du lịch", "đi xa", "Chuyển nhà", "Nhập trạch"]
        case .contract:
            return ["Ký hợp đồng", "Giao dịch", "ký", "Buôn bán"]
        case .ancestorWorship:
            return ["Cúng", "Lễ", "Cầu an", "Tụng kinh", "giỗ", "Cúng tế"]
        }
    }

    /// Bad stars that especially conflict with this purpose.
    var conflictingBadStars: [ExtendedBadStar] {
        switch self {
        case .wedding:
            return [.khongPhong, .lySao, .quaTu, .thuTu, .quyKhoc]
        case .opening, .contract:
            return [.daiHao, .tieuHao, .thuTu, .diaPha]
        case .groundbreaking:
            return [.diaPha, .thienCuong, .cuuThoQuy, .thuTu]
        case .travel:
            return [.lySao, .phiMaSat, .kiepSat, .thuTu]
        case .ancestorWorship:
            return [.thuTu, .quyKhoc]
        }
    }

    /// Whether Lục Hắc Đạo should block this purpose.
    var blockedByLucHacDao: Bool {
        switch self {
        case .ancestorWorship:
            return false
        default:
            return true
        }
    }
}
