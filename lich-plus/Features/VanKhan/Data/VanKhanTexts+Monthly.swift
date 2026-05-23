//
//  VanKhanTexts+Monthly.swift
//  lich-plus
//
//  Template bodies for monthly occasions. Placeholders are typed via
//  `VanKhanToken` (interpolated, not plaintext) so typos fail at compile time.
//
//  Sources (per "Văn khấn cổ truyền Việt Nam" – NXB Văn hóa Thông tin):
//    • Mùng 1 hằng tháng: vetted (existing).
//    • Rằm hằng tháng: VOV2, Znews, Thanh Niên (3 nguồn đối chiếu).
//    • Thần Tài – Thổ Địa: VOV, Znews (2 nguồn đối chiếu).
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

            Chúng con kính mời các cụ Tổ khảo, Tổ tỷ, chư vị hương linh gia tiên nội ngoại họ \(T.familyName), cúi xin thương xót con cháu linh thiêng hiện về, chứng giám tâm thành, thụ hưởng lễ vật.

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

            Con kính lạy ngài Bản cảnh Thành Hoàng, ngài Bản xứ Thổ địa, ngài Bản gia Táo quân cùng chư vị Tôn thần.

            Con kính lạy Cao Tằng Tổ Khảo, Cao Tằng Tổ Tỷ, Thúc Bá Đệ Huynh, Cô Di, Tỷ Muội họ nội họ ngoại.

            Tín chủ (chúng) con là: \(T.name)
            Ngụ tại: \(T.address)

            Hôm nay là ngày \(T.lunarDate) (nhằm ngày \(T.solarDate)), tín chủ con nhờ ơn đức Trời Đất, chư vị Tôn thần, cù lao tiên tổ, thành tâm sắm lễ, hương hoa trà quả, thắp nén tâm hương dâng lên trước án.

            Chúng con kính mời ngài Bản cảnh Thành Hoàng chư vị Đại Vương, ngài Bản xứ Thần linh Thổ địa, ngài Bản gia Táo quân, Ngũ phương, Long mạch, Tài thần. Cúi xin các ngài giáng lâm trước án, chứng giám lòng thành, thụ hưởng lễ vật.

            Chúng con kính mời các cụ Tổ Khảo, Tổ Tỷ, chư vị Hương linh gia tiên nội ngoại họ \(T.familyName), cúi xin thương xót con cháu, linh thiêng hiện về, chứng giám tâm thành, thụ hưởng lễ vật.

            Tín chủ con lại kính mời các vị vong linh Tiền chủ, Hậu chủ ở trong nhà này, đất này đồng lâm án tiền, đồng lai hâm hưởng.

            Nguyện xin các ngài che chở, phù hộ độ trì cho gia đạo chúng con cơ đồ vượng phát, gia đạo bình an, sở cầu như ý, sở nguyện tòng tâm, bốn mùa không hạn ách, tám tiết hưởng thanh bình.

            Chúng con lễ bạc tâm thành, trước án kính lễ, cúi xin được phù hộ độ trì.

            Nam mô A Di Đà Phật! (3 lần)
            """
        ),

        VanKhanText(
            occasionId: "than-tai-tho-dia",
            body: """
            Nam mô A Di Đà Phật! (3 lần)

            Con lạy chín phương Trời, mười phương Chư Phật, Chư Phật mười phương.

            Kính lạy ngài Hoàng Thiên Hậu Thổ chư vị Tôn thần.

            Con kính lạy ngài Đông Trù Tư mệnh Táo phủ Thần quân.

            Con kính lạy Thần Tài vị tiền.

            Con kính lạy các ngài Thần linh, Thổ địa cai quản trong xứ này.

            Tín chủ con là: \(T.name)
            Ngụ tại: \(T.address)

            Hôm nay là ngày \(T.lunarDate), nhằm ngày \(T.solarDate).

            Tín chủ thành tâm sửa biện hương hoa, lễ vật, kim ngân, trà quả và các thứ cúng dâng, bày ra trước án kính mời ngài Thần Tài vị tiền.

            Cúi xin Thần Tài thương xót tín chủ, giáng lâm trước án, chứng giám lòng thành, thụ hưởng lễ vật, phù trì tín chủ chúng con an ninh khang thái, vạn sự tốt lành, gia đạo hưng long thịnh vượng, lộc tài tăng tiến, tâm đạo mở mang, sở cầu tất ứng, sở nguyện tòng tâm.

            Chúng con lễ bạc tâm thành, trước án kính lễ, cúi xin được phù hộ độ trì.

            Nam mô A Di Đà Phật! (3 lần)
            """
        ),
    ]
}
