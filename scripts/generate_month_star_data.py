#!/usr/bin/env python3
"""Generate Month3StarData.swift and Month7StarData.swift from book transcriptions."""

from __future__ import annotations

CAN_CHI_ORDER = [
    "Giáp Tý", "Ất Sửu", "Bính Dần", "Đinh Mão", "Mậu Thìn", "Kỷ Tỵ",
    "Canh Ngọ", "Tân Mùi", "Nhâm Thân", "Quý Dậu", "Giáp Tuất", "Ất Hợi",
    "Bính Tý", "Đinh Sửu", "Mậu Dần", "Kỷ Mão", "Canh Thìn", "Tân Tỵ",
    "Nhâm Ngọ", "Quý Mùi", "Giáp Thân", "Ất Dậu", "Bính Tuất", "Đinh Hợi",
    "Mậu Tý", "Kỷ Sửu", "Canh Dần", "Tân Mão", "Nhâm Thìn", "Quý Tỵ",
    "Giáp Ngọ", "Ất Mùi", "Bính Thân", "Đinh Dậu", "Mậu Tuất", "Kỷ Hợi",
    "Canh Tý", "Tân Sửu", "Nhâm Dần", "Quý Mão", "Giáp Thìn", "Ất Tỵ",
    "Bính Ngọ", "Đinh Mùi", "Mậu Thân", "Kỷ Dậu", "Canh Tuất", "Tân Hợi",
    "Nhâm Tý", "Quý Sửu", "Giáp Dần", "Ất Mão", "Bính Thìn", "Đinh Tỵ",
    "Mậu Ngọ", "Kỷ Mùi", "Canh Thân", "Tân Dậu", "Nhâm Tuất", "Quý Hợi",
]

# (good_stars, bad_stars) — extracted from Lịch Vạn Niên pages 116-121 (month 3)
MONTH_3: dict[str, tuple[list[str], list[str]]] = {
    "Giáp Tý": (["thienAn"], ["hoangSa", "khongPhong"]),
    "Ất Sửu": (["thienAn", "satCong"], ["tuThoiCoQua", "tieuHongSa", "diaPha", "hoangVu", "huyenVu", "bangTieu", "nguHu"]),
    "Bính Dần": (["thienAn", "trucLinh"], ["hoaTai"]),
    "Đinh Mão": ([], ["nguyetHoa", "cauTran"]),
    "Mậu Thìn": ([], ["khongPhong", "nguHu", "lySao"]),
    "Kỷ Tỵ": (["nhanChuyen"], ["kiepSat", "hoangVu", "loiCong", "khongPhong", "lySao"]),
    "Canh Ngọ": ([], ["thienHoa", "thoOn", "phiMaSat", "quaTu"]),
    "Tân Mùi": ([], ["thienCuong", "tieuHao", "nguyetHu"]),
    "Nhâm Thân": ([], ["daiHao", "nguyetYem", "hoaTinh"]),
    "Quý Dậu": ([], ["hoangVu", "lySao"]),
    "Giáp Tuất": (["satCong"], ["cuuKhong", "quyKhoc"]),
    "Ất Hợi": (["trucLinh"], ["thuTu"]),
    "Bính Tý": ([], ["hoangSa", "khongPhong"]),
    "Đinh Sửu": ([], ["tuThoiCoQua", "tieuHongSa", "diaPha", "hoangVu", "huyenVu", "bangTieu", "nguHu", "cuuThoQuy"]),
    "Mậu Dần": (["thienThuy", "nhanChuyen"], ["hoaTai", "lySao"]),
    "Kỷ Mão": (["thienThuy", "thienAn"], ["nguyetHoa", "cauTran"]),
    "Canh Thìn": (["thienAn"], ["khongPhong", "nguHu"]),
    "Tân Tỵ": (["thienThuy", "thienAn"], ["kiepSat", "hoangVu", "loiCong", "nguHu", "khongPhong", "hoaTinh", "lySao"]),
    "Nhâm Ngọ": (["thienAn"], ["thienHoa", "thoOn", "phiMaSat", "quaTu"]),
    "Quý Mùi": (["thienAn", "satCong"], ["thienCuong", "tieuHao", "nguyetHu"]),
    "Giáp Thân": (["trucLinh"], ["daiHao", "nguyetYem"]),
    "Ất Dậu": ([], ["cuuThoQuy", "hoangVu", "nguHu", "lySao"]),
    "Bính Tuất": ([], ["cuuKhong", "quyKhoc"]),
    "Đinh Hợi": (["nhanChuyen"], ["thuTu"]),
    "Mậu Tý": ([], ["lySao", "hoangSa", "khongPhong"]),
    "Kỷ Sửu": (["thienThuy"], ["tuThoiCoQua", "tieuHongSa", "diaPha", "hoangVu", "huyenVu", "bangTieu", "nguHu", "lySao"]),
    "Canh Dần": (["thienThuy"], ["hoaTinh", "hoaTai"]),
    "Tân Mão": ([], ["nguyetHoa", "cauTran", "lySao"]),
    "Nhâm Thìn": (["satCong"], ["nguQuy", "khongPhong"]),
    "Quý Tỵ": (["trucLinh"], ["cuuThoQuy", "lySao", "kiepSat", "hoangVu", "loiCong", "nguHu", "khongPhong"]),
    "Giáp Ngọ": ([], ["cuuThoQuy", "thienHoa", "thoOn", "phiMaSat", "quaTu"]),
    "Ất Mùi": (["nhanChuyen"], ["thienCuong", "tieuHao", "nguyetHu"]),
    "Bính Thân": (["nhanChuyen"], ["daiHao", "nguyetYem"]),
    "Đinh Dậu": ([], ["hoangVu", "nguHu", "lySao"]),
    "Mậu Tuất": ([], ["cuuKhong", "quyKhoc", "lySao"]),
    "Kỷ Hợi": ([], ["hoaTinh", "thuTu"]),
    "Canh Tý": (["satCong"], ["hoangSa", "khongPhong"]),
    "Tân Sửu": (["satCong"], ["tuThoiCoQua", "tieuHongSa", "diaPha", "hoangVu", "nguHu", "huyenVu", "bangTieu", "cuuThoQuy", "lySao"]),
    "Nhâm Dần": (["trucLinh"], ["hoaTai", "cuuThoQuy"]),
    "Quý Mão": ([], ["nguyetHoa", "cauTran"]),
    "Giáp Thìn": (["satCong"], ["khongPhong", "nguQuy"]),
    "Ất Tỵ": (["nhanChuyen"], ["kiepSat", "hoangVu", "loiCong", "nguHu", "khongPhong"]),
    "Bính Ngọ": ([], ["thienHoa", "thoOn", "phiMaSat", "quaTu"]),
    "Đinh Mùi": ([], ["thienCuong", "tieuHao", "nguyetHu"]),
    "Mậu Thân": ([], ["daiHao", "nguyetYem", "hoaTinh", "lySao"]),
    "Kỷ Dậu": ([], ["hoangVu", "nguHu", "lySao", "cuuThoQuy"]),
    "Canh Tuất": (["thienAn", "satCong"], ["cuuKhong", "quyKhoc", "cuuThoQuy"]),
    "Tân Hợi": (["thienAn", "trucLinh"], ["thuTu"]),
    "Nhâm Tý": (["thienThuy"], ["hoangSa", "khongPhong"]),
    "Quý Sửu": (["thienAn"], ["tuThoiCoQua", "tieuHongSa", "diaPha", "hoangVu", "nguHu", "huyenVu", "bangTieu"]),
    "Giáp Dần": (["nhanChuyen"], ["hoaTai"]),
    "Ất Mão": ([], ["nguyetHoa", "cauTran"]),
    "Bính Thìn": ([], ["thoOn", "nguQuy", "khongPhong"]),
    "Đinh Tỵ": ([], ["kiepSat", "hoangVu", "loiCong", "nguHu", "khongPhong", "hoaTinh"]),
    "Mậu Ngọ": (["ngoHop"], ["thienHoa", "thoOn", "phiMaSat", "quaTu"]),
    "Kỷ Mùi": (["ngoHop", "satCong"], ["thienCuong", "tieuHao", "nguyetHu"]),
    "Canh Thân": (["trucLinh"], ["daiHao", "nguyetYem"]),
    "Tân Dậu": (["ngoHop"], ["hoangVu", "nguHu", "lySao"]),
    "Nhâm Tuất": ([], ["cuuKhong", "quyKhoc", "lySao"]),
    "Quý Hợi": (["ngoHop", "nhanChuyen"], ["thuTu", "hoaTinh"]),
}

# (good_stars, bad_stars) — extracted from Lịch Vạn Niên pages 140-145 (month 7)
MONTH_7: dict[str, tuple[list[str], list[str]]] = {
    "Giáp Tý": (["thienAn"], ["daiHao"]),
    "Ất Sửu": (["thienAn"], ["thuTu", "nguQuy", "hoaTinh"]),
    "Bính Dần": (["thienAn"], ["khongPhong"]),
    "Đinh Mão": (["thienAn", "satCong"], ["hoangVu", "nguHu"]),
    "Mậu Thìn": (["thienAn", "trucLinh"], ["hoaTai", "nguyetYem", "lySao"]),
    "Kỷ Tỵ": ([], ["tieuHongSa", "kiepSat", "diaPha", "loiCong", "lySao"]),
    "Canh Ngọ": ([], ["thienHoa", "hoangSa", "phiMaSat"]),
    "Tân Mùi": (["nhanChuyen"], ["hoangVu", "nguyetHu", "tuThoiCoQua"]),
    "Nhâm Thân": (["thienAn"], []),
    "Quý Dậu": ([], ["huyenVu"]),
    "Giáp Tuất": ([], ["thoOn", "quaTu", "lySao", "quyKhoc", "hoaTinh"]),
    "Ất Hợi": ([], ["thienCuong", "tieuHao", "hoangVu", "nguyetHoa", "bangTieu", "cauTran", "nguHu"]),
    "Bính Tý": ([], ["daiHao"]),
    "Đinh Sửu": (["trucLinh"], ["thuTu", "nguQuy", "cuuThoQuy"]),
    "Mậu Dần": (["thienThuy"], ["khongPhong", "lySao"]),
    "Kỷ Mão": (["thienThuy", "thienAn"], ["hoangVu", "nguHu"]),
    "Canh Thìn": (["thienAn", "nhanChuyen"], ["hoaTai", "nguyetYem"]),
    "Tân Tỵ": (["thienThuy", "thienAn"], ["tieuHongSa", "kiepSat", "diaPha", "loiCong", "lySao"]),
    "Nhâm Ngọ": (["thienAn"], ["thienHoa", "hoangSa", "phiMaSat"]),
    "Quý Mùi": (["thienAn"], ["hoangVu", "nguyetHu", "nguHu", "tuThoiCoQua", "hoaTinh"]),
    # Giáp Thân: book columns B/C have no enum-mappable stars (Thổ phủ, Lục bất thành only)
    "Giáp Thân": ([], []),
    "Ất Dậu": (["satCong"], ["thoOn", "quaTu", "lySao", "quyKhoc", "huyenVu", "cuuThoQuy"]),
    "Bính Tuất": (["trucLinh"], ["thoOn", "quaTu", "lySao", "quyKhoc"]),
    "Đinh Hợi": ([], ["thienCuong", "tieuHao", "hoangVu", "nguyetHoa", "bangTieu", "cauTran", "nguHu"]),
    "Mậu Tý": ([], ["daiHao", "lySao"]),
    "Kỷ Sửu": ([], ["thuTu", "nguQuy", "lySao"]),
    "Canh Dần": (["thienThuy"], ["khongPhong"]),
    "Tân Mão": ([], ["hoangVu", "nguHu", "lySao"]),
    "Nhâm Thìn": ([], ["hoaTai", "nguyetYem"]),
    "Quý Tỵ": ([], ["tieuHongSa", "kiepSat", "diaPha", "loiCong", "lySao", "cuuThoQuy"]),
    "Giáp Ngọ": (["satCong"], ["cuuThoQuy", "thienHoa", "hoangSa", "phiMaSat"]),
    "Ất Mùi": (["trucLinh"], ["hoangVu", "nguyetHu", "nguHu", "tuThoiCoQua"]),
    # Bính Thân: book columns B/C have no enum-mappable stars (Thổ phủ, Lục bất thành only)
    "Bính Thân": ([], []),
    "Đinh Dậu": ([], ["huyenVu"]),
    "Mậu Tuất": (["nhanChuyen"], ["thoOn", "quaTu", "lySao", "quyKhoc"]),
    "Kỷ Hợi": ([], ["thienCuong", "tieuHao", "hoangVu", "nguyetHoa", "bangTieu", "cauTran", "nguHu"]),
    "Canh Tý": ([], ["daiHao"]),
    "Tân Sửu": ([], ["thuTu", "nguQuy", "cuuThoQuy", "hoaTinh"]),
    "Nhâm Dần": ([], ["khongPhong", "cuuThoQuy"]),
    "Quý Mão": (["satCong"], ["hoangVu", "nguHu"]),
    "Giáp Thìn": (["trucLinh"], ["hoaTai", "nguyetYem"]),
    "Ất Tỵ": ([], ["tieuHongSa", "kiepSat", "diaPha", "loiCong"]),
    "Bính Ngọ": ([], ["thienHoa", "hoangSa", "phiMaSat"]),
    "Đinh Mùi": (["nhanChuyen"], ["hoangVu", "nguyetHu", "nguHu", "tuThoiCoQua"]),
    "Mậu Thân": ([], ["lySao"]),
    "Kỷ Dậu": ([], ["huyenVu", "lySao", "cuuThoQuy"]),
    "Canh Tuất": (["thienAn"], ["thoOn", "quaTu", "lySao", "quyKhoc", "cuuThoQuy", "hoaTinh"]),
    "Tân Hợi": (["thienAn"], ["thienCuong", "tieuHao", "hoangVu", "nguyetHoa", "bangTieu", "cauTran", "nguHu"]),
    "Nhâm Tý": (["satCong"], ["daiHao"]),
    "Quý Sửu": (["trucLinh"], ["thuTu", "nguQuy"]),
    "Giáp Dần": ([], ["khongPhong"]),
    "Ất Mão": ([], ["hoangVu", "nguHu"]),
    "Bính Thìn": (["nhanChuyen"], ["hoaTai", "nguyetYem"]),
    "Đinh Tỵ": ([], ["tieuHongSa", "kiepSat", "diaPha", "loiCong"]),
    "Mậu Ngọ": (["ngoHop"], ["cuuThoQuy", "lySao", "thienHoa", "hoangSa", "phiMaSat"]),
    "Kỷ Mùi": (["ngoHop"], ["hoangVu", "nguyetHu", "nguHu", "tuThoiCoQua", "hoaTinh"]),
    "Canh Thân": (["satCong", "ngoHop"], ["daiHao", "nguyetYem"]),
    "Tân Dậu": (["trucLinh"], ["huyenVu"]),
    "Nhâm Tuất": ([], ["thoOn", "quaTu", "lySao", "quyKhoc"]),
    "Quý Hợi": ([], ["thienCuong", "tieuHao", "hoangVu", "nguyetHoa", "bangTieu", "cauTran", "nguHu"]),
}


def format_stars(stars: list[str]) -> str:
    if not stars:
        return "[]"
    return "[" + ", ".join(f".{s}" for s in stars) + "]"


def generate_swift(month: int, page_range: str, data: dict[str, tuple[list[str], list[str]]]) -> str:
    lines = [
        "//",
        f"//  Month{month}StarData.swift",
        "//  lich-plus",
        "//",
        f"//  Month {month} Star Data from Lịch Vạn Niên 2005-2009, Pages {page_range}",
        "//",
        f"//  COMPLETE DATA: All 60 Can-Chi combinations extracted from book",
        f"//  Source: Lịch Vạn Niên 2005-2009, Tháng {month} âm lịch, Pages {page_range}",
        "//",
        "",
        "import Foundation",
        "",
        f"/// Month {month} (Tháng {month} âm lịch) star data",
        f"/// Source: Lịch Vạn Niên 2005-2009, Pages {page_range}",
        f"struct Month{month}StarData {{",
        "",
        f"    static let data = MonthStarData(month: {month}, dayData: createDayData())",
        "",
        "    private static func createDayData() -> [String: DayStarData] {",
        "        var data: [String: DayStarData] = [:]",
        "",
        f"        // MARK: - Complete Month {month} Data (All 60 Can-Chi Combinations)",
        f"        // Extracted from book pages {page_range}, columns B (Sao xấu) and C (Sao tốt)",
        "",
    ]

    gaps: list[str] = []
    for i, can_chi in enumerate(CAN_CHI_ORDER, start=1):
        good, bad = data[can_chi]
        if not good and not bad:
            gaps.append(can_chi)
        lines.append(f"        // Row {i}: {can_chi}")
        if not good and not bad:
            lines.append(f"        // NOTE: Book lists only stars outside current enum (no B/C enum mapping)")
        lines.append(
            f'        data["{can_chi}"] = DayStarData(canChi: "{can_chi}", '
            f"goodStars: {format_stars(good)}, badStars: {format_stars(bad)})"
        )
        lines.append("")

    lines.extend([
        "        return data",
        "    }",
        "",
        "    static var dataCompleteness: (completed: Int, total: Int) {",
        "        let populated = data.dayData.values.filter(\\.hasAnyStars).count",
        "        return (populated, 60)",
        "    }",
        "",
        "    static func printDataStatus() {",
        "        let status = dataCompleteness",
        "        let percentage = Double(status.completed) / Double(status.total) * 100.0",
        f'        print("Month {month} Star Data: \\(status.completed)/\\(status.total) entries (\\(String(format: "%.1f", percentage))%)")',
    ])

    if gaps:
        gap_list = ", ".join(gaps)
        lines.extend([
            f'        print("⚠️ WARNING: {len(gaps)} row(s) have no enum-mappable stars: {gap_list}")',
        ])

    lines.extend([
        "    }",
        "}",
        "",
    ])

    return "\n".join(lines)


def main() -> None:
    root = "/workspace/lich-plus/Features/Calendar/Data"
    month3 = generate_swift(3, "116-121", MONTH_3)
    month7 = generate_swift(7, "140-145", MONTH_7)

    with open(f"{root}/Month3StarData.swift", "w", encoding="utf-8") as f:
        f.write(month3)
    with open(f"{root}/Month7StarData.swift", "w", encoding="utf-8") as f:
        f.write(month7)

    m3_pop = sum(1 for g, b in MONTH_3.values() if g or b)
    m7_pop = sum(1 for g, b in MONTH_7.values() if g or b)
    print(f"Month 3: {m3_pop}/60 populated")
    print(f"Month 7: {m7_pop}/60 populated")
    m7_gaps = [k for k, (g, b) in MONTH_7.items() if not g and not b]
    if m7_gaps:
        print(f"Month 7 residual gaps: {m7_gaps}")


if __name__ == "__main__":
    main()
