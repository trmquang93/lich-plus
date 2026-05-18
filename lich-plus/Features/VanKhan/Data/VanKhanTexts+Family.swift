//
//  VanKhanTexts+Family.swift
//  lich-plus
//
//  Template bodies for family events: cưới hỏi, nhập trạch, đầy tháng, thôi nôi.
//
//  TODO: Replace stub text with vetted Vietnamese sources before shipping.
//

import Foundation

extension VanKhanLibrary {

    static let familyTexts: [VanKhanText] = [
        VanKhanText(
            occasionId: "cuoi-hoi",
            body: """
            Nam mô A Di Đà Phật! (3 lần)

            Con kính lạy chín phương Trời, mười phương Chư Phật.
            Con kính lạy Hoàng Thiên Hậu Thổ chư vị Tôn thần.
            Con kính lạy Tổ tiên nội ngoại chư vị Hương linh.

            Tín chủ con là: {name}
            Ngụ tại: {address}

            Hôm nay ngày {solarDate} (nhằm ngày {lunarDate}), nhân lễ cưới hỏi, tín chủ con thành tâm dâng lễ vật, hương hoa, trà quả kính cáo gia tiên.

            [TODO: nội dung khấn lễ cưới gia tiên — tra cứu nguồn chính thống]

            Cúi xin chư vị Tôn thần và Gia tiên chứng giám, phù hộ cho đôi tân lang tân nương trăm năm hạnh phúc, đầu bạc răng long.

            Nam mô A Di Đà Phật! (3 lần)
            """
        ),

        VanKhanText(
            occasionId: "nhap-trach",
            body: """
            Nam mô A Di Đà Phật! (3 lần)

            Con kính lạy chín phương Trời, mười phương Chư Phật.
            Con kính lạy Hoàng Thiên Hậu Thổ chư vị Tôn thần.
            Con kính lạy ngài Đương cảnh Thành Hoàng, ngài Bản xứ Thổ địa, ngài Định Phúc Táo Quân.

            Tín chủ con là: {name}
            Hôm nay chuyển đến cư ngụ tại: {address}

            Tín chủ con thành tâm dâng lễ vật, hương hoa, trà quả kính cáo chư vị Tôn thần.

            [TODO: nội dung khấn nhập trạch — tra cứu nguồn chính thống]

            Cúi xin chư vị chứng giám lòng thành, phù hộ độ trì cho gia đình ở nơi đây được bình an, vạn sự hanh thông.

            Nam mô A Di Đà Phật! (3 lần)
            """
        ),

        VanKhanText(
            occasionId: "day-thang",
            body: """
            Nam mô A Di Đà Phật! (3 lần)

            Con kính lạy chư vị Tôn thần, đặc biệt là Mười hai Bà Mụ và Đức Bà Chúa Tiên.

            Tín chủ con là: {name}
            Ngụ tại: {address}

            Hôm nay là ngày đầy tháng của cháu {childName}. Tín chủ con thành tâm sắm sửa lễ vật, hương hoa, trà quả, xôi chè kính dâng lên trước án.

            [TODO: nội dung khấn đầy tháng — tra cứu nguồn chính thống]

            Cúi xin chư vị Bà Mụ, các vị Tôn thần phù hộ độ trì cho cháu {childName} hay ăn chóng lớn, mạnh khoẻ, thông minh.

            Nam mô A Di Đà Phật! (3 lần)
            """
        ),

        VanKhanText(
            occasionId: "thoi-noi",
            body: """
            Nam mô A Di Đà Phật! (3 lần)

            Con kính lạy chư vị Tôn thần, Mười hai Bà Mụ, Đức Ông và Đức Bà Chúa Tiên.

            Tín chủ con là: {name}
            Ngụ tại: {address}

            Hôm nay là ngày Thôi Nôi (tròn 1 tuổi) của cháu {childName}. Tín chủ con thành tâm dâng lễ vật, hương hoa, xôi chè kính cẩn dâng lên trước án.

            [TODO: nội dung khấn thôi nôi — tra cứu nguồn chính thống]

            Cúi xin chư vị Bà Mụ, các vị Tôn thần và Gia tiên chứng giám lòng thành, phù hộ cho cháu {childName} mạnh khoẻ, ngoan ngoãn, học hành tấn tới.

            Nam mô A Di Đà Phật! (3 lần)
            """
        ),
    ]

    // MARK: - Lookup

    static func text(for occasionId: String) -> VanKhanText? {
        let all = monthlyTexts + festivalTexts + anniversaryTexts + familyTexts
        return all.first { $0.occasionId == occasionId }
    }
}
