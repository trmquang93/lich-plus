//
//  VanKhanTexts+Monthly.swift
//  lich-plus
//
//  Template bodies for monthly occasions. Tokens: {name}, {address},
//  {lunarDate}, {solarDate}, {gender}, {childName}.
//
//  TODO: Replace stub text with vetted Vietnamese sources (cite per file
//  before shipping). See risks in van-khan-plan.md.
//

import Foundation

extension VanKhanLibrary {

    static let monthlyTexts: [VanKhanText] = [
        VanKhanText(
            occasionId: "mung-1-hang-thang",
            body: """
            Nam mô A Di Đà Phật! (3 lần)

            Con lạy chín phương Trời, mười phương Chư Phật, Chư Phật mười phương.
            Con kính lạy Hoàng Thiên Hậu Thổ chư vị Tôn thần.
            Con kính lạy ngài Bản cảnh Thành Hoàng, ngài Bản xứ Thổ địa, ngài Bản gia Táo Quân cùng chư vị Tôn Thần.
            Con kính lạy Tổ tiên, Hiển khảo, Hiển tỷ, chư vị Hương linh.

            Tín chủ con là: {name}
            Ngụ tại: {address}

            Hôm nay là ngày {lunarDate} (nhằm ngày {solarDate}), tín chủ con thành tâm sửa biện hương hoa lễ vật, kim ngân trà quả, đốt nén tâm hương dâng lên trước án.

            [TODO: thêm nội dung cầu khấn theo nguồn chính thống]

            Chúng con lễ bạc tâm thành, trước án kính lễ, cúi xin được phù hộ độ trì.

            Nam mô A Di Đà Phật! (3 lần)
            """
        ),

        VanKhanText(
            occasionId: "ram-hang-thang",
            body: """
            Nam mô A Di Đà Phật! (3 lần)

            Con lạy chín phương Trời, mười phương Chư Phật, Chư Phật mười phương.
            Con kính lạy Hoàng Thiên Hậu Thổ chư vị Tôn thần.
            Con kính lạy ngài Bản cảnh Thành Hoàng, ngài Bản xứ Thổ địa, ngài Bản gia Táo Quân cùng chư vị Tôn Thần.
            Con kính lạy Tổ tiên nội ngoại, chư vị Hương linh.

            Tín chủ con là: {name}
            Ngụ tại: {address}

            Hôm nay là ngày Rằm {lunarDate} (nhằm ngày {solarDate}), tín chủ con thành tâm sắm sửa lễ vật, hương hoa trà quả dâng lên trước án.

            [TODO: thêm nội dung cầu khấn theo nguồn chính thống]

            Chúng con lễ bạc tâm thành, cúi xin chư vị Tôn thần và Gia tiên thương xót phù hộ độ trì cho toàn gia an khang thịnh vượng.

            Nam mô A Di Đà Phật! (3 lần)
            """
        ),

        VanKhanText(
            occasionId: "than-tai-tho-dia",
            body: """
            Nam mô A Di Đà Phật! (3 lần)

            Con lạy chín phương Trời, mười phương Chư Phật.
            Con kính lạy ngài Thần Tài tiền vị, ngài Thổ Địa cai quản trong xứ này.

            Tín chủ con là: {name}
            Cư ngụ tại: {address}

            Hôm nay là ngày {lunarDate} (nhằm ngày {solarDate}), tín chủ con thành tâm dâng lễ vật, hương hoa, trà quả, kính cẩn tâu lên trước án.

            [TODO: thêm nội dung cầu tài lộc theo nguồn chính thống]

            Cúi xin Thần Tài, Thổ Địa chứng giám lòng thành, phù hộ độ trì cho gia chủ buôn may bán đắt, vạn sự hanh thông.

            Nam mô A Di Đà Phật! (3 lần)
            """
        ),
    ]
}
