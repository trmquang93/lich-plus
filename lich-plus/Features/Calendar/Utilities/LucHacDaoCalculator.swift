//
//  LucHacDaoCalculator.swift
//  lich-plus
//
//  Lục Hắc Đạo (Six Unlucky Days) Calculator
//  Vietnamese astrology system for detecting inauspicious days
//
//  The six unlucky day types are determined by the lunar month and day Chi (Earthly Branch)
//  These days override or significantly diminish positive qualities from other systems like 12 Trực
//

import Foundation

// MARK: - Lục Hắc Đạo Calculator

struct LucHacDaoCalculator {

    // MARK: - Unlucky Day Types

    /// The six unlucky day types in Vietnamese astrology
    enum UnluckyDayType: String, CaseIterable, Equatable {
        case chuTuoc = "Chu Tước Hắc Đạo"
        case bachHo = "Bạch Hổ Hắc Đạo"
        case cauTran = "Câu Trận Hắc Đạo"
        case thienLao = "Thiên Lao Hắc Đạo"
        case thienHinh = "Thiên Hình"
        case nguyenVu = "Nguyên Vũ"

        var vietnameseName: String {
            return self.rawValue
        }

        var description: String {
            switch self {
            case .chuTuoc:
                return "Chu Tước Hắc Đạo - Ngày vô cùng xấu, nên tránh mọi hoạt động quan trọng"
            case .bachHo:
                return "Bạch Hổ Hắc Đạo - Ngày xấu, tránh khởi động việc quan trọng"
            case .cauTran:
                return "Câu Trận Hắc Đạo - Ngày không may, cẩn thận trong mọi việc"
            case .thienLao:
                return "Thiên Lao Hắc Đạo - Ngày xấu, tránh đi xa, ký hợp đồng"
            case .thienHinh:
                return "Thiên Hình - Ngày xấu, tránh kiện tụng, tranh chấp"
            case .nguyenVu:
                return "Nguyên Vũ - Ngày xấu, cẩn thận với các hoạt động quan trọng"
            }
        }
    }

    // MARK: - Unlucky Day Calculation

    /// Calculate if a lunar date is an unlucky day and return its type
    ///
    /// The six unlucky days are determined by the combination of lunar month and day Chi (Earthly Branch).
    /// Each month has specific Chi values that trigger each unlucky day type.
    ///
    /// Reference: Traditional Vietnamese astrology system
    ///
    /// - Parameters:
    ///   - lunarMonth: The lunar month (1-12)
    ///   - dayChi: The day's Chi (Earthly Branch from Can-Chi pair)
    /// - Returns: The UnluckyDayType if the day is unlucky, nil otherwise
    static func calculateUnluckyDay(
        lunarMonth: Int,
        dayChi: ChiEnum
    ) -> UnluckyDayType? {

        // Rules for each unlucky day type based on month and Chi
        // These rules come from traditional Vietnamese astrology

        switch (lunarMonth, dayChi) {

        // MARK: - Chu Tước Hắc Đạo
        // Occurs in months 1, 4, 7, 10 for specific Chi values
        case (1, .ty), (1, .suu):
            return .chuTuoc
        case (4, .dau):
            return .chuTuoc
        case (7, .thin):  // Thìn = 4
            return .chuTuoc
        case (9, .mui):
            return .chuTuoc
        case (10, .dau):
            return .chuTuoc

        // MARK: - Bạch Hổ Hắc Đạo
        // Occurs in months 2, 3, 5, 8, 11 for specific Chi values
        case (2, .dan):  // Dần = 2
            return .bachHo
        case (3, .tuat):  // Added: Month 3 + Chi Tuất (from xemngay.com validation)
            return .bachHo
        case (5, .thin):  // Thìn = 4
            return .bachHo
        case (8, .suu):
            return .bachHo
        case (11, .tuat):
            return .bachHo

        // MARK: - Câu Trận
        // Occurs in months 1, 3, 6, 9, 10, 12 for specific Chi values
        case (1, .hoi):  // Added: Month 1 + Chi Hợi (from xemngay.com validation)
            return .cauTran
        case (3, .dan):
            return .cauTran
        case (6, .mao):
            return .cauTran
        case (9, .dau):
            return .cauTran
        case (10, .ty2):  // Added: Month 10 + Chi Tỵ (discovered from xemngay.com data)
            return .cauTran
        case (12, .hoi):
            return .cauTran

        // MARK: - Thiên Lao Hắc Đạo
        // Prison-related unlucky day
        // Specific month and Chi combinations
        case (1, .mao):
            return .thienLao
        case (4, .ngo):
            return .thienLao
        case (7, .dau):
            return .thienLao
        case (7, .than):  // Added: Month 7 + Chi Thân (from xemngay.com validation)
            return .thienLao
        case (9, .ty):  // Added: Month 9 + Chi Tý (discovered from xemngay.com data)
            return .thienLao
        case (10, .suu):
            return .thienLao
        case (10, .ty):  // Added: Month 10 + Chi Tý (discovered from xemngay.com data)
            return .thienLao

        // MARK: - Thiên Hình
        // Punishment-related unlucky day
        case (2, .ty):
            return .thienHinh
        case (5, .mao):
            return .thienHinh
        case (8, .ngo):
            return .thienHinh
        case (10, .than):
            return .thienHinh
        case (11, .dau):
            return .thienHinh

        // MARK: - Nguyên Vũ
        // Black martial/soldier day
        case (3, .suu):
            return .nguyenVu
        case (6, .suu):
            return .nguyenVu
        case (9, .suu):
            return .nguyenVu
        case (12, .suu):
            return .nguyenVu

        default:
            return nil
        }
    }

    /// Get all unlucky days for a specific lunar month
    /// Useful for calendar views that highlight entire months
    ///
    /// - Parameter lunarMonth: The lunar month (1-12)
    /// - Returns: Array of (unluckyDayType, affectedChis)
    static func getUnluckyDaysForMonth(_ lunarMonth: Int) -> [(type: UnluckyDayType, affectedChis: [ChiEnum])] {
        var results: [UnluckyDayType: [ChiEnum]] = [:]

        for chi in ChiEnum.allCases {
            if let unluckyType = calculateUnluckyDay(lunarMonth: lunarMonth, dayChi: chi) {
                if results[unluckyType] == nil {
                    results[unluckyType] = []
                }
                results[unluckyType]?.append(chi)
            }
        }

        return results.map { (type: $0.key, affectedChis: $0.value) }
    }

    /// Check if a lunar date falls on any unlucky day
    ///
    /// - Parameters:
    ///   - lunarDay: The lunar day
    ///   - lunarMonth: The lunar month
    ///   - dayCanChi: The day Can-Chi pair (to extract Chi)
    /// - Returns: true if the date is an unlucky day
    static func isUnluckyDay(
        lunarDay: Int,
        lunarMonth: Int,
        dayCanChi: CanChiPair
    ) -> Bool {
        return calculateUnluckyDay(lunarMonth: lunarMonth, dayChi: dayCanChi.chi) != nil
    }
}

// MARK: - Extensions

extension LucHacDaoCalculator.UnluckyDayType {
    /// Severity of the unlucky day (for UI/UX purposes)
    var severity: Int {
        switch self {
        case .chuTuoc:
            return 5  // Most severe
        case .thienHinh, .thienLao:
            return 4
        case .bachHo, .cauTran:
            return 3
        case .nguyenVu:
            return 2  // Least severe
        }
    }

    /// Color for UI visualization
    var uiColor: String {
        switch self {
        case .chuTuoc, .thienHinh, .thienLao:
            return "red"      // Most severe - red
        case .bachHo, .cauTran:
            return "orange"   // Moderate - orange
        case .nguyenVu:
            return "yellow"   // Mild - yellow
        }
    }
}
