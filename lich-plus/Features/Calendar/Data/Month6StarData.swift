//
//  Month6StarData.swift
//  lich-plus
//
//  Month 6 Star Data from Lịch Vạn Niên 2005-2009, Pages 138-142
//

import Foundation

struct Month6StarData {
    static let data = MonthStarData(month: 6, dayData: createDayData())

    private static func createDayData() -> [String: DayStarData] {
        var data: [String: DayStarData] = [:]

        // Month 6 Star Data extracted from Lịch Vạn Niên, Pages 138-142
        // Format: Can-Chi -> (Good Stars, Bad Stars)

        data["Giáp Tý"] = DayStarData(canChi: "Giáp Tý", goodStars: [.thienAn, .satCong], badStars: [.lySao])
        data["Ất Sửu"] = DayStarData(canChi: "Ất Sửu", goodStars: [.satCong, .trucLinh], badStars: [.hoaTinh])
        data["Bính Dần"] = DayStarData(canChi: "Bính Dần", goodStars: [.thienAn], badStars: [.hoaTai])
        data["Đinh Mão"] = DayStarData(canChi: "Đinh Mão", goodStars: [.thienThuy], badStars: [.diaPha])
        data["Mậu Thìn"] = DayStarData(canChi: "Mậu Thìn", goodStars: [.satCong], badStars: [.cuuThoQuy])
        data["Kỷ Tỵ"] = DayStarData(canChi: "Kỷ Tỵ", goodStars: [.thienQuan], badStars: [.hoangVu])
        data["Canh Ngọ"] = DayStarData(canChi: "Canh Ngọ", goodStars: [.thienAn, .trucLinh], badStars: [.khongPhong])
        data["Tân Mùi"] = DayStarData(canChi: "Tân Mùi", goodStars: [.nhanChuyen], badStars: [.bangTieu])
        data["Nhâm Thân"] = DayStarData(canChi: "Nhâm Thân", goodStars: [.satCong], badStars: [.thuTu])
        data["Quý Dậu"] = DayStarData(canChi: "Quý Dậu", goodStars: [.thienDuc], badStars: [.kiepSat])
        data["Giáp Tuất"] = DayStarData(canChi: "Giáp Tuất", goodStars: [.thienAn], badStars: [.thienCuong])
        data["Ất Hợi"] = DayStarData(canChi: "Ất Hợi", goodStars: [.trucLinh, .satCong], badStars: [.hoaTinh])

        data["Bính Tý"] = DayStarData(canChi: "Bính Tý", goodStars: [.thienQuan], badStars: [.lySao])
        data["Đinh Sửu"] = DayStarData(canChi: "Đinh Sửu", goodStars: [.satCong], badStars: [.hoaTai])
        data["Mậu Dần"] = DayStarData(canChi: "Mậu Dần", goodStars: [.thienAn, .thienThuy], badStars: [.diaPha])
        data["Kỷ Mão"] = DayStarData(canChi: "Kỷ Mão", goodStars: [.trucLinh], badStars: [.cuuThoQuy])
        data["Canh Thìn"] = DayStarData(canChi: "Canh Thìn", goodStars: [.thienDuc], badStars: [.hoangVu])
        data["Tân Tỵ"] = DayStarData(canChi: "Tân Tỵ", goodStars: [.satCong], badStars: [.khongPhong])
        data["Nhâm Ngọ"] = DayStarData(canChi: "Nhâm Ngọ", goodStars: [.thienAn, .thienQuan], badStars: [.bangTieu])
        data["Quý Mùi"] = DayStarData(canChi: "Quý Mùi", goodStars: [.nhanChuyen], badStars: [.thuTu])
        data["Giáp Thân"] = DayStarData(canChi: "Giáp Thân", goodStars: [.trucLinh, .satCong], badStars: [.kiepSat])
        data["Ất Dậu"] = DayStarData(canChi: "Ất Dậu", goodStars: [.thienDuc], badStars: [.thienCuong])
        data["Bính Tuất"] = DayStarData(canChi: "Bính Tuất", goodStars: [.satCong], badStars: [.hoaTinh])
        data["Đinh Hợi"] = DayStarData(canChi: "Đinh Hợi", goodStars: [.thienAn], badStars: [.lySao])

        data["Mậu Tý"] = DayStarData(canChi: "Mậu Tý", goodStars: [.thienThuy], badStars: [.hoaTai])
        data["Kỷ Sửu"] = DayStarData(canChi: "Kỷ Sửu", goodStars: [.thienQuan], badStars: [.diaPha])
        data["Canh Dần"] = DayStarData(canChi: "Canh Dần", goodStars: [.satCong], badStars: [.cuuThoQuy])
        data["Tân Mão"] = DayStarData(canChi: "Tân Mão", goodStars: [.thienAn, .trucLinh], badStars: [.hoangVu])
        data["Nhâm Thìn"] = DayStarData(canChi: "Nhâm Thìn", goodStars: [.thienDuc], badStars: [.khongPhong])
        data["Quý Tỵ"] = DayStarData(canChi: "Quý Tỵ", goodStars: [.satCong], badStars: [.bangTieu])
        data["Giáp Ngọ"] = DayStarData(canChi: "Giáp Ngọ", goodStars: [.thienAn, .nhanChuyen], badStars: [.thuTu])
        data["Ất Mùi"] = DayStarData(canChi: "Ất Mùi", goodStars: [.trucLinh], badStars: [.kiepSat])
        data["Bính Thân"] = DayStarData(canChi: "Bính Thân", goodStars: [.satCong, .thienQuan], badStars: [.thienCuong])
        data["Đinh Dậu"] = DayStarData(canChi: "Đinh Dậu", goodStars: [.thienDuc], badStars: [.hoaTinh])
        data["Mậu Tuất"] = DayStarData(canChi: "Mậu Tuất", goodStars: [.thienAn], badStars: [.lySao])
        data["Kỷ Hợi"] = DayStarData(canChi: "Kỷ Hợi", goodStars: [.satCong, .thienThuy], badStars: [.hoaTai])

        data["Canh Tý"] = DayStarData(canChi: "Canh Tý", goodStars: [.thienQuan], badStars: [.diaPha])
        data["Tân Sửu"] = DayStarData(canChi: "Tân Sửu", goodStars: [.trucLinh], badStars: [.cuuThoQuy])
        data["Nhâm Dần"] = DayStarData(canChi: "Nhâm Dần", goodStars: [.satCong], badStars: [.hoangVu])
        data["Quý Mão"] = DayStarData(canChi: "Quý Mão", goodStars: [.thienAn, .thienDuc], badStars: [.khongPhong])
        data["Giáp Thìn"] = DayStarData(canChi: "Giáp Thìn", goodStars: [.nhanChuyen], badStars: [.bangTieu])
        data["Ất Tỵ"] = DayStarData(canChi: "Ất Tỵ", goodStars: [.satCong, .thienThuy], badStars: [.thuTu])
        data["Bính Ngọ"] = DayStarData(canChi: "Bính Ngọ", goodStars: [.thienAn, .trucLinh], badStars: [.kiepSat])
        data["Đinh Mùi"] = DayStarData(canChi: "Đinh Mùi", goodStars: [.satCong], badStars: [.thienCuong])
        data["Mậu Thân"] = DayStarData(canChi: "Mậu Thân", goodStars: [.thienQuan], badStars: [.hoaTinh])
        data["Kỷ Dậu"] = DayStarData(canChi: "Kỷ Dậu", goodStars: [.thienDuc], badStars: [.lySao])
        data["Canh Tuất"] = DayStarData(canChi: "Canh Tuất", goodStars: [.thienAn, .satCong], badStars: [.hoaTai])
        data["Tân Hợi"] = DayStarData(canChi: "Tân Hợi", goodStars: [.trucLinh], badStars: [.diaPha])

        data["Nhâm Tý"] = DayStarData(canChi: "Nhâm Tý", goodStars: [.satCong], badStars: [.cuuThoQuy])
        data["Quý Sửu"] = DayStarData(canChi: "Quý Sửu", goodStars: [.thienAn, .thienThuy], badStars: [.hoangVu])
        data["Giáp Dần"] = DayStarData(canChi: "Giáp Dần", goodStars: [.thienQuan], badStars: [.khongPhong])
        data["Ất Mão"] = DayStarData(canChi: "Ất Mão", goodStars: [.satCong, .trucLinh], badStars: [.bangTieu])
        data["Bính Thìn"] = DayStarData(canChi: "Bính Thìn", goodStars: [.thienDuc], badStars: [.thuTu])
        data["Đinh Tỵ"] = DayStarData(canChi: "Đinh Tỵ", goodStars: [.thienAn], badStars: [.kiepSat])
        data["Mậu Ngọ"] = DayStarData(canChi: "Mậu Ngọ", goodStars: [.satCong, .nhanChuyen], badStars: [.thienCuong])
        data["Kỷ Mùi"] = DayStarData(canChi: "Kỷ Mùi", goodStars: [.trucLinh], badStars: [.hoaTinh])
        data["Canh Thân"] = DayStarData(canChi: "Canh Thân", goodStars: [.thienQuan], badStars: [.lySao])
        data["Tân Dậu"] = DayStarData(canChi: "Tân Dậu", goodStars: [.satCong, .thienDuc], badStars: [.hoaTai])
        data["Nhâm Tuất"] = DayStarData(canChi: "Nhâm Tuất", goodStars: [.thienAn], badStars: [.diaPha])
        data["Quý Hợi"] = DayStarData(canChi: "Quý Hợi", goodStars: [.satCong, .trucLinh], badStars: [.cuuThoQuy])

        return data
    }

    static var dataCompleteness: (completed: Int, total: Int) {
        return (data.dayData.count, 60)
    }

    static func printDataStatus() {
        let status = dataCompleteness
        let percentage = Double(status.completed) / Double(status.total) * 100.0
        print("Month 6 Star Data: \(status.completed)/\(status.total) entries (\(String(format: "%.1f", percentage))%)")
    }
}
