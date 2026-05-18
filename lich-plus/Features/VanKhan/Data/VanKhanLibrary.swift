//
//  VanKhanLibrary.swift
//  lich-plus
//
//  Catalogue of văn khấn occasions (metadata only).
//  Text bodies live in `VanKhanTexts+*.swift` files.
//

import Foundation

enum VanKhanLibrary {

    static let allOccasions: [VanKhanOccasion] = monthly + festivals + anniversary + family

    // MARK: - Monthly

    static let monthly: [VanKhanOccasion] = [
        VanKhanOccasion(
            id: "mung-1-hang-thang",
            title: "Văn khấn Mùng 1 hằng tháng",
            subtitle: "Cúng gia tiên ngày mùng 1 âm lịch",
            category: .monthly,
            trigger: .lunarDay(1)
        ),
        VanKhanOccasion(
            id: "ram-hang-thang",
            title: "Văn khấn Rằm hằng tháng",
            subtitle: "Cúng gia tiên ngày 15 âm lịch",
            category: .monthly,
            trigger: .lunarDay(15)
        ),
        VanKhanOccasion(
            id: "than-tai-tho-dia",
            title: "Văn khấn Thần Tài – Thổ Địa",
            subtitle: "Cúng Thần Tài hằng ngày / mùng 10 âm lịch",
            category: .monthly,
            trigger: .lunarDate(month: 1, day: 10)
        ),
    ]

    // MARK: - Festivals

    static let festivals: [VanKhanOccasion] = [
        VanKhanOccasion(
            id: "giao-thua",
            title: "Văn khấn Giao Thừa",
            subtitle: "Đêm 30 (hoặc 29) tháng Chạp",
            category: .festival,
            trigger: .lunarLastDayOfYear
        ),
        VanKhanOccasion(
            id: "nguyen-dan",
            title: "Văn khấn Tết Nguyên Đán",
            subtitle: "Mùng 1 tháng Giêng",
            category: .festival,
            trigger: .lunarDate(month: 1, day: 1)
        ),
        VanKhanOccasion(
            id: "ram-thang-gieng",
            title: "Văn khấn Rằm tháng Giêng",
            subtitle: "Tết Nguyên Tiêu — 15/1 âm lịch",
            category: .festival,
            trigger: .lunarDate(month: 1, day: 15)
        ),
        VanKhanOccasion(
            id: "ong-cong-ong-tao",
            title: "Văn khấn Ông Công Ông Táo",
            subtitle: "23 tháng Chạp",
            category: .festival,
            trigger: .lunarDate(month: 12, day: 23)
        ),
        VanKhanOccasion(
            id: "thanh-minh",
            title: "Văn khấn Tiết Thanh Minh",
            subtitle: "Khoảng đầu tháng 4 dương lịch",
            category: .festival,
            trigger: .solar(month: 4, day: 4)
        ),
        VanKhanOccasion(
            id: "vu-lan",
            title: "Văn khấn Vu Lan",
            subtitle: "Rằm tháng 7 âm lịch",
            category: .festival,
            trigger: .lunarDate(month: 7, day: 15)
        ),
        VanKhanOccasion(
            id: "trung-thu",
            title: "Văn khấn Tết Trung Thu",
            subtitle: "Rằm tháng 8 âm lịch",
            category: .festival,
            trigger: .lunarDate(month: 8, day: 15)
        ),
    ]

    // MARK: - Anniversary (Giỗ)

    static let anniversary: [VanKhanOccasion] = [
        VanKhanOccasion(
            id: "gio",
            title: "Văn khấn Giỗ",
            subtitle: "Ngày giỗ của người đã khuất",
            category: .anniversary,
            trigger: .anniversary
        ),
    ]

    // MARK: - Family events

    static let family: [VanKhanOccasion] = [
        VanKhanOccasion(
            id: "cuoi-hoi",
            title: "Văn khấn Lễ Cưới hỏi (Gia tiên)",
            subtitle: "Báo cáo gia tiên ngày cưới",
            category: .family,
            trigger: .manual
        ),
        VanKhanOccasion(
            id: "nhap-trach",
            title: "Văn khấn Nhập trạch",
            subtitle: "Lễ về nhà mới",
            category: .family,
            trigger: .manual
        ),
        VanKhanOccasion(
            id: "day-thang",
            title: "Văn khấn Đầy tháng",
            subtitle: "Lễ đầy tháng cho bé",
            category: .family,
            trigger: .manual
        ),
        VanKhanOccasion(
            id: "thoi-noi",
            title: "Văn khấn Thôi nôi",
            subtitle: "Lễ thôi nôi (1 tuổi) cho bé",
            category: .family,
            trigger: .manual
        ),
    ]

    static func occasion(id: String) -> VanKhanOccasion? {
        allOccasions.first { $0.id == id }
    }

    static func grouped() -> [(VanKhanCategory, [VanKhanOccasion])] {
        VanKhanCategory.allCases.map { cat in
            (cat, allOccasions.filter { $0.category == cat })
        }
    }
}
