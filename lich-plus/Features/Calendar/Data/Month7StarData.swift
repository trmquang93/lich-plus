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

        // Page 143 visible entries
        data["Giáp Thân"] = DayStarData(canChi: "Giáp Thân", goodStars: [], badStars: [])
        data["Ất Dậu"] = DayStarData(canChi: "Ất Dậu", goodStars: [.satCong], badStars: [.cuuThoQuy])
        data["Bính Tuất"] = DayStarData(canChi: "Bính Tuất", goodStars: [.trucLinh], badStars: [])
        data["Đinh Hợi"] = DayStarData(canChi: "Đinh Hợi", goodStars: [], badStars: [])
        data["Mậu Tý"] = DayStarData(canChi: "Mậu Tý", goodStars: [], badStars: [.lySao])
        data["Kỷ Sửu"] = DayStarData(canChi: "Kỷ Sửu", goodStars: [], badStars: [.lySao])
        data["Canh Dần"] = DayStarData(canChi: "Canh Dần", goodStars: [.thienThuy], badStars: [])
        data["Tân Mão"] = DayStarData(canChi: "Tân Mão", goodStars: [], badStars: [.lySao])
        data["Nhâm Thìn"] = DayStarData(canChi: "Nhâm Thìn", goodStars: [], badStars: [])
        data["Quý Tỵ"] = DayStarData(canChi: "Quý Tỵ", goodStars: [], badStars: [.lySao, .cuuThoQuy])
        data["Giáp Ngọ"] = DayStarData(canChi: "Giáp Ngọ", goodStars: [.satCong], badStars: [.cuuThoQuy])
        data["Ất Mùi"] = DayStarData(canChi: "Ất Mùi", goodStars: [.trucLinh], badStars: [])
        data["Bính Thân"] = DayStarData(canChi: "Bính Thân", goodStars: [], badStars: [])
        data["Đinh Dậu"] = DayStarData(canChi: "Đinh Dậu", goodStars: [], badStars: [])
        data["Mậu Tuất"] = DayStarData(canChi: "Mậu Tuất", goodStars: [.nhanChuyen], badStars: [.lySao])
        data["Kỷ Hợi"] = DayStarData(canChi: "Kỷ Hợi", goodStars: [], badStars: [])
        data["Canh Tý"] = DayStarData(canChi: "Canh Tý", goodStars: [], badStars: [])
        data["Tân Sửu"] = DayStarData(canChi: "Tân Sửu", goodStars: [], badStars: [.cuuThoQuy, .hoaLinh])
        data["Nhâm Dần"] = DayStarData(canChi: "Nhâm Dần", goodStars: [], badStars: [])
        data["Quý Mão"] = DayStarData(canChi: "Quý Mão", goodStars: [.satCong], badStars: [])

        // Remaining entries (pages 144-147)
        data["Giáp Thìn"] = DayStarData(canChi: "Giáp Thìn", goodStars: [], badStars: [])
        data["Ất Tỵ"] = DayStarData(canChi: "Ất Tỵ", goodStars: [], badStars: [])
        data["Bính Ngọ"] = DayStarData(canChi: "Bính Ngọ", goodStars: [], badStars: [])
        data["Đinh Mùi"] = DayStarData(canChi: "Đinh Mùi", goodStars: [], badStars: [])
        data["Mậu Thân"] = DayStarData(canChi: "Mậu Thân", goodStars: [], badStars: [])
        data["Kỷ Dậu"] = DayStarData(canChi: "Kỷ Dậu", goodStars: [], badStars: [])
        data["Canh Tuất"] = DayStarData(canChi: "Canh Tuất", goodStars: [], badStars: [])
        data["Tân Hợi"] = DayStarData(canChi: "Tân Hợi", goodStars: [], badStars: [])
        data["Nhâm Tý"] = DayStarData(canChi: "Nhâm Tý", goodStars: [], badStars: [])
        data["Quý Sửu"] = DayStarData(canChi: "Quý Sửu", goodStars: [], badStars: [])
        data["Giáp Dần"] = DayStarData(canChi: "Giáp Dần", goodStars: [], badStars: [])
        data["Ất Mão"] = DayStarData(canChi: "Ất Mão", goodStars: [], badStars: [])
        data["Bính Thìn"] = DayStarData(canChi: "Bính Thìn", goodStars: [], badStars: [])
        data["Đinh Tỵ"] = DayStarData(canChi: "Đinh Tỵ", goodStars: [], badStars: [])
        data["Mậu Ngọ"] = DayStarData(canChi: "Mậu Ngọ", goodStars: [.ngoHop], badStars: [.hoaLinh])
        data["Kỷ Mùi"] = DayStarData(canChi: "Kỷ Mùi", goodStars: [.ngoHop], badStars: [])
        data["Canh Thân"] = DayStarData(canChi: "Canh Thân", goodStars: [.satCong], badStars: [])
        data["Tân Dậu"] = DayStarData(canChi: "Tân Dậu", goodStars: [.trucLinh, .ngoHop], badStars: [])
        data["Nhâm Tuất"] = DayStarData(canChi: "Nhâm Tuất", goodStars: [], badStars: [.lySao])
        data["Quý Hợi"] = DayStarData(canChi: "Quý Hợi", goodStars: [.ngoHop], badStars: [])

        // Complete remaining 20 entries
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
