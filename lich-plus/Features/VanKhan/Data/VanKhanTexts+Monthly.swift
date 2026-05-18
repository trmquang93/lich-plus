//
//  VanKhanTexts+Monthly.swift
//  lich-plus
//
//  Template bodies for monthly occasions. Placeholders are typed via
//  `VanKhanToken` (interpolated, not plaintext) so typos fail at compile time.
//
//  TODO: Replace stub text with vetted Vietnamese sources (cite per file
//  before shipping). See risks in van-khan-plan.md.
//

import Foundation

private typealias T = VanKhanToken

extension VanKhanLibrary {

    static let monthlyTexts: [VanKhanText] = [
        VanKhanText(
            occasionId: "mung-1-hang-thang",
            body: """
            Nam mô A Di Đà Phật! (3 lần)

            Con lạy chín phương Trời, mười phương chư Phật, chư Phật mười phương.

            Con kính lạy Hoàng thiên, Hậu Thổ chư vị Tôn thần.

            Con kính lạy ngài Bản cảnh Thành hoàng, ngài Bản xứ Thổ địa, ngài Bản gia Táo quân cùng chư vị Tôn thần.

            Con kính lạy tổ tiên, Hiển khảo, Hiển tỷ, chư vị hương linh (nếu bố, mẹ còn sống thì thay bằng Tổ khảo, Tổ tỷ).

            Hương chủ (chúng) con tên là: \(T.name)
            Sống tại: \(T.address)

            Hôm nay là ngày \(T.lunarDate) (nhằm ngày \(T.solarDate)), tín chủ con nhờ ơn đức trời đất, chư vị Tôn thần, cù lao tiên tổ, thành tâm sắm lễ, hương, hoa, trà, quả, thắp nén tâm hương dâng lên trước án.

            Chúng con kính mời: Ngài Bản cảnh Thành hoàng chư vị đại vương, ngài Bản xứ Thần linh Thổ địa, ngài Bản gia Táo quân, Ngũ phương, Long mạch, Tài thần. Cúi xin các ngài giáng lâm trước án, chứng giám lòng thành thụ hưởng lễ vật.

            \(VanKhanSectionTag.ancestors.open)
            Chúng con kính mời các cụ Tổ khảo, Tổ tỷ, chư vị hương linh gia tiên nội ngoại họ \(T.familyName), cúi xin thương xót con cháu linh thiêng hiện về, chứng giám tâm thành, thụ hưởng lễ vật.
            \(VanKhanSectionTag.ancestors.close)

            Tín chủ con lại kính mời các vị Tiền chủ, Hậu chủ ngụ tại nhà này, đồng lâm án tiền, đồng lai hâm hưởng, phù hộ cho gia đình chúng con luôn luôn mạnh khỏe, mọi sự bình an, vạn sự tốt lành, làm ăn phát tài, gia đình hòa thuận.

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

            Tín chủ con là: \(T.name)
            Ngụ tại: \(T.address)

            Hôm nay là ngày Rằm \(T.lunarDate) (nhằm ngày \(T.solarDate)), tín chủ con thành tâm sắm sửa lễ vật, hương hoa trà quả dâng lên trước án.

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

            Tín chủ con là: \(T.name)
            Cư ngụ tại: \(T.address)

            Hôm nay là ngày \(T.lunarDate) (nhằm ngày \(T.solarDate)), tín chủ con thành tâm dâng lễ vật, hương hoa, trà quả, kính cẩn tâu lên trước án.

            [TODO: thêm nội dung cầu tài lộc theo nguồn chính thống]

            Cúi xin Thần Tài, Thổ Địa chứng giám lòng thành, phù hộ độ trì cho gia chủ buôn may bán đắt, vạn sự hanh thông.

            Nam mô A Di Đà Phật! (3 lần)
            """
        ),
    ]
}
