//
//  Month3StarData.swift
//  lich-plus
//
//  Month 3 Star Data from Lịch Vạn Niên 2005-2009
//

import Foundation

struct Month3StarData {
    static let data = MonthStarData(month: 3, dayData: createDayData())

    private static func createDayData() -> [String: DayStarData] {
        var data: [String: DayStarData] = [:]

        // Create all 60 Can-Chi entries
        let canChis = [
            "Giáp Tý", "Ất Sửu", "Bính Dần", "Đinh Mão", "Mậu Thìn", "Kỷ Tỵ",
            "Canh Ngọ", "Tân Mùi", "Nhâm Thân", "Quý Dậu", "Giáp Tuất", "Ất Hợi",
            "Bính Tý", "Đinh Sửu", "Mậu Dần", "Kỷ Mão", "Canh Thìn", "Tân Tỵ",
            "Nhâm Ngọ", "Quý Mùi", "Giáp Thân", "Ất Dậu", "Bính Tuất", "Đinh Hợi",
            "Mậu Tý", "Kỷ Sửu", "Canh Dần", "Tân Mão", "Nhâm Thìn", "Quý Tỵ",
            "Giáp Ngọ", "Ất Mùi", "Bính Thân", "Đinh Dậu", "Mậu Tuất", "Kỷ Hợi",
            "Canh Tý", "Tân Sửu", "Nhâm Dần", "Quý Mão", "Giáp Thìn", "Ất Tỵ",
            "Bính Ngọ", "Đinh Mùi", "Mậu Thân", "Kỷ Dậu", "Canh Tuất", "Tân Hợi",
            "Nhâm Tý", "Quý Sửu", "Giáp Dần", "Ất Mão", "Bính Thìn", "Đinh Tỵ",
            "Mậu Ngọ", "Kỷ Mùi", "Canh Thân", "Tân Dậu", "Nhâm Tuất", "Quý Hợi"
        ]

        // Initialize all entries with empty stars
        for canChi in canChis {
            data[canChi] = DayStarData(canChi: canChi, goodStars: [], badStars: [])
        }

        // Month 3 Star Data from Lịch Vạn Niên 2005-2009, Pages 119-120
        // Data extracted from Column B (Sao xấu) and Column C (Sao tốt)
        // Source: Tháng 3 âm lịch (Month 3 of Lunar Calendar)

        // Position 21: Ất Dậu
        data["Ất Dậu"] = DayStarData(canChi: "Ất Dậu", goodStars: [], badStars: [.cuuThoQuy, .hoangVu, .nguHu, .lySao])

        // Position 22: Bính Tuất
        data["Bính Tuất"] = DayStarData(canChi: "Bính Tuất", goodStars: [], badStars: [.cuuKhong, .quyKhoc])

        // Position 23: Đinh Hợi
        data["Đinh Hợi"] = DayStarData(canChi: "Đinh Hợi", goodStars: [.nhanChuyen], badStars: [.thuTu])

        // Position 24: Mậu Tý
        data["Mậu Tý"] = DayStarData(canChi: "Mậu Tý", goodStars: [], badStars: [.lySao, .hoangSa, .khongPhong])

        // Position 25: Kỷ Sửu
        data["Kỷ Sửu"] = DayStarData(canChi: "Kỷ Sửu", goodStars: [.thienThuy], badStars: [.lySao, .diaPha, .hoangVu, .huyenVu, .bangTieu, .nguHu])

        // Position 26: Canh Dần
        data["Canh Dần"] = DayStarData(canChi: "Canh Dần", goodStars: [.thienThuy], badStars: [.hoaTinh, .hoaTai])

        // Position 27: Tân Mào
        data["Tân Mão"] = DayStarData(canChi: "Tân Mào", goodStars: [], badStars: [.nguyetHoa, .cauTran])

        // Position 28: Nhâm Thìn
        data["Nhâm Thìn"] = DayStarData(canChi: "Nhâm Thìn", goodStars: [.satCong], badStars: [.nguQuy, .khongPhong])

        // Position 29: Quý Tỵ
        data["Quý Tỵ"] = DayStarData(canChi: "Quý Tỵ", goodStars: [.trucLinh], badStars: [.cuuThoQuy, .lySao, .kiepSat, .hoangVu, .loiCong, .nguHu, .khongPhong])

        // Position 30: Giáp Ngọ
        data["Giáp Ngọ"] = DayStarData(canChi: "Giáp Ngọ", goodStars: [], badStars: [.cuuThoQuy, .thienHoa, .thoOn, .phiMaSat, .quaTu])

        // Position 31: Ất Mùi
        data["Ất Mùi"] = DayStarData(canChi: "Ất Mùi", goodStars: [.nhanChuyen], badStars: [.thienCuong, .tieuHao, .nguyetHu])

        // Position 32: Bính Thân
        data["Bính Thân"] = DayStarData(canChi: "Bính Thân", goodStars: [], badStars: [.daiHao, .nguyetYem])

        // Position 33: Đinh Dậu
        data["Đinh Dậu"] = DayStarData(canChi: "Đinh Dậu", goodStars: [], badStars: [.hoangVu, .nguHu, .lySao])

        // Position 34: Mậu Tuất
        data["Mậu Tuất"] = DayStarData(canChi: "Mậu Tuất", goodStars: [.ngoHop], badStars: [.cuuThoQuy, .hoaTinh, .thienHoa, .hoaTai, .hoangVu, .nguHu, .phiMaSat])

        // Position 35: Kỷ Hợi
        data["Kỷ Hợi"] = DayStarData(canChi: "Kỷ Hợi", goodStars: [.ngoHop], badStars: [.hoaTinh, .thuTu])

        // Position 36: Canh Tý
        data["Canh Tý"] = DayStarData(canChi: "Canh Tý", goodStars: [.satCong], badStars: [.hoangSa, .khongPhong])

        // Position 37: Tân Sửu
        data["Tân Sửu"] = DayStarData(canChi: "Tân Sửu", goodStars: [.trucLinh, .ngoHop], badStars: [.cuuThoQuy, .lySao, .diaPha, .hoangVu, .huyenVu, .bangTieu, .nguHu, .tieuHongSa])

        // Position 38: Nhâm Dần
        data["Nhâm Dần"] = DayStarData(canChi: "Nhâm Dần", goodStars: [], badStars: [.lySao, .hoangVu, .tuThoiCoQua, .nguHu, .quyKhoc])

        // Position 39: Quý Mào
        data["Quý Mào"] = DayStarData(canChi: "Quý Mào", goodStars: [.ngoHop], badStars: [])

        // Position 40: Giáp Thìn
        data["Giáp Thìn"] = DayStarData(canChi: "Giáp Thìn", goodStars: [.trucLinh], badStars: [.daiHao, .nguyetYem])

        return data
    }

    static var dataCompleteness: (completed: Int, total: Int) {
        return (data.dayData.count, 60)
    }

    static func printDataStatus() {
        let status = dataCompleteness
        let percentage = Double(status.completed) / Double(status.total) * 100.0
        print("Month 3 Star Data: \(status.completed)/\(status.total) entries (\(String(format: "%.1f", percentage))%)")
    }
}
