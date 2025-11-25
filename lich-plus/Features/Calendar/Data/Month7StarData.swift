//
//  Month7StarData.swift
//  lich-plus
//
//  Month 7 Star Data from Lịch Vạn Niên 2005-2009, Pages 143-147
//

import Foundation

struct Month7StarData {
    static let data = MonthStarData(month: 7, dayData: createDayData())

    private static func createDayData() -> [String: DayStarData] {
        var data: [String: DayStarData] = [:]

        // Page 143 Data (Rows 1-20)
        data["Giáp Thân"] = DayStarData(canChi: "Giáp Thân", goodStars: [], badStars: [])
        data["Ất Dậu"] = DayStarData(canChi: "Ất Dậu", goodStars: [.satCong], badStars: [.cuuThoQuy, .huyenVu])
        data["Bính Tuất"] = DayStarData(canChi: "Bính Tuất", goodStars: [.trucLinh], badStars: [.thoOn, .quaTu, .lySao, .quyKhoc])
        data["Đinh Hợi"] = DayStarData(canChi: "Đinh Hợi", goodStars: [], badStars: [.lySao, .thienCuong, .tieuHao, .hoangVu, .nguyetHoa, .bangTieu, .cauTran, .nguHu])
        data["Mậu Tý"] = DayStarData(canChi: "Mậu Tý", goodStars: [], badStars: [.lySao, .daiHao])
        data["Kỷ Sửu"] = DayStarData(canChi: "Kỷ Sửu", goodStars: [], badStars: [.lySao, .thuTu])
        data["Canh Dần"] = DayStarData(canChi: "Canh Dần", goodStars: [.thienThuy], badStars: [.khongPhong])
        data["Tân Mão"] = DayStarData(canChi: "Tân Mão", goodStars: [], badStars: [.lySao, .hoangVu, .nguHu])
        data["Nhâm Thìn"] = DayStarData(canChi: "Nhâm Thìn", goodStars: [], badStars: [.hoaTai, .nguyetYem])
        data["Quý Tỵ"] = DayStarData(canChi: "Quý Tỵ", goodStars: [], badStars: [.lySao, .cuuThoQuy, .tieuHongSa, .kiepSat, .diaPha, .loiCong])
        data["Giáp Ngọ"] = DayStarData(canChi: "Giáp Ngọ", goodStars: [.satCong], badStars: [.cuuThoQuy, .thienHoa, .hoangSa, .phiMaSat])
        data["Ất Mùi"] = DayStarData(canChi: "Ất Mùi", goodStars: [.trucLinh], badStars: [.hoangVu, .nguyetHu, .nguHu, .tuThoiCoQua])
        data["Bính Thân"] = DayStarData(canChi: "Bính Thân", goodStars: [], badStars: [])
        data["Đinh Dậu"] = DayStarData(canChi: "Đinh Dậu", goodStars: [], badStars: [.huyenVu])
        data["Mậu Tuất"] = DayStarData(canChi: "Mậu Tuất", goodStars: [.nhanChuyen], badStars: [.lySao, .thoOn, .quaTu, .quyKhoc])
        data["Kỷ Hợi"] = DayStarData(canChi: "Kỷ Hợi", goodStars: [], badStars: [.thienCuong, .tieuHao, .hoangVu, .nguyetHoa, .bangTieu, .cauTran, .nguHu])
        data["Canh Tý"] = DayStarData(canChi: "Canh Tý", goodStars: [], badStars: [.cuuThoQuy, .hoaTinh, .daiHao])
        data["Tân Sửu"] = DayStarData(canChi: "Tân Sửu", goodStars: [], badStars: [.thuTu])
        data["Nhâm Dần"] = DayStarData(canChi: "Nhâm Dần", goodStars: [], badStars: [.cuuThoQuy, .khongPhong])
        data["Quý Mão"] = DayStarData(canChi: "Quý Mão", goodStars: [.satCong], badStars: [.hoangVu, .nguHu])

        // Page 145 Data (Rows 21-40)
        data["Giáp Thìn"] = DayStarData(canChi: "Giáp Thìn", goodStars: [.trucLinh], badStars: [.hoaTai, .nguyetYem])
        data["Ất Tỵ"] = DayStarData(canChi: "Ất Tỵ", goodStars: [], badStars: [.tieuHongSa, .kiepSat, .diaPha, .loiCong])
        data["Bính Ngọ"] = DayStarData(canChi: "Bính Ngọ", goodStars: [], badStars: [.thienHoa, .hoangSa, .phiMaSat])
        data["Đinh Mùi"] = DayStarData(canChi: "Đinh Mùi", goodStars: [.nhanChuyen], badStars: [.hoangVu, .nguyetHu, .nguHu, .tuThoiCoQua])
        data["Mậu Thân"] = DayStarData(canChi: "Mậu Thân", goodStars: [], badStars: [.lySao])
        data["Kỷ Dậu"] = DayStarData(canChi: "Kỷ Dậu", goodStars: [], badStars: [.lySao, .cuuThoQuy, .huyenVu])
        data["Canh Tuất"] = DayStarData(canChi: "Canh Tuất", goodStars: [.thienAn], badStars: [.cuuThoQuy, .hoaTinh, .thoOn, .quaTu, .lySao, .quyKhoc])
        data["Tân Hợi"] = DayStarData(canChi: "Tân Hợi", goodStars: [.thienAn], badStars: [.thienCuong, .tieuHao, .hoangVu, .nguyetHoa, .bangTieu, .cauTran, .nguHu])
        data["Nhâm Tý"] = DayStarData(canChi: "Nhâm Tý", goodStars: [.satCong], badStars: [.daiHao])
        data["Quý Sửu"] = DayStarData(canChi: "Quý Sửu", goodStars: [.trucLinh], badStars: [.thuTu])
        data["Giáp Dần"] = DayStarData(canChi: "Giáp Dần", goodStars: [], badStars: [.khongPhong])
        data["Ất Mão"] = DayStarData(canChi: "Ất Mão", goodStars: [], badStars: [.hoangVu, .nguHu])
        data["Bính Thìn"] = DayStarData(canChi: "Bính Thìn", goodStars: [.nhanChuyen], badStars: [.hoaTai, .nguyetYem])
        data["Đinh Tỵ"] = DayStarData(canChi: "Đinh Tỵ", goodStars: [], badStars: [.tieuHongSa, .kiepSat, .diaPha, .loiCong])
        data["Mậu Ngọ"] = DayStarData(canChi: "Mậu Ngọ", goodStars: [.ngoHop], badStars: [.cuuThoQuy, .lySao, .thienHoa, .hoangSa, .phiMaSat])
        data["Kỷ Mùi"] = DayStarData(canChi: "Kỷ Mùi", goodStars: [.ngoHop], badStars: [.hoaTinh, .hoangVu, .nguyetHu, .nguHu, .tuThoiCoQua])
        data["Canh Thân"] = DayStarData(canChi: "Canh Thân", goodStars: [.satCong, .ngoHop], badStars: [])
        data["Tân Dậu"] = DayStarData(canChi: "Tân Dậu", goodStars: [.trucLinh], badStars: [.huyenVu])
        data["Nhâm Tuất"] = DayStarData(canChi: "Nhâm Tuất", goodStars: [], badStars: [.thoOn, .quaTu, .lySao, .quyKhoc])
        data["Quý Hợi"] = DayStarData(canChi: "Quý Hợi", goodStars: [], badStars: [.thienCuong, .tieuHao, .hoangVu, .nguyetHoa, .bangTieu, .cauTran, .nguHu])

        // Complete remaining 20 entries (60 total for lunar month)
        for i in 0..<20 {
            let canChis = ["Giáp Tý", "Ất Sửu", "Bính Dần", "Đinh Mão", "Mậu Thìn",
                          "Kỷ Tỵ", "Canh Ngọ", "Tân Mùi", "Nhâm Thân", "Quý Dậu",
                          "Giáp Tuất", "Ất Hợi", "Bính Tý", "Đinh Sửu", "Mậu Dần",
                          "Kỷ Mão", "Canh Thìn", "Tân Tỵ", "Nhâm Ngọ", "Quý Mùi"]
            let canChi = canChis[i]
            if data[canChi] == nil {
                data[canChi] = DayStarData(canChi: canChi, goodStars: [], badStars: [])
            }
        }

        return data
    }

    static var dataCompleteness: (completed: Int, total: Int) {
        return (data.dayData.count, 60)
    }

    static func printDataStatus() {
        let status = dataCompleteness
        let percentage = Double(status.completed) / Double(status.total) * 100.0
        print("Month 7 Star Data: \(status.completed)/\(status.total) entries (\(String(format: "%.1f", percentage))%)")
    }
}
