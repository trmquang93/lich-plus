//
//  VanKhanTexts+Festivals.swift
//  lich-plus
//
//  Template bodies for festival occasions. Placeholders are typed via
//  `VanKhanToken` interpolation.
//
//  Sources (per "Văn khấn cổ truyền Việt Nam" – NXB Văn hóa Thông tin):
//    • Giao Thừa (trong nhà): VietnamNet (2 bài đối chiếu).
//    • Nguyên Đán: VietnamNet, VOV2.
//    • Rằm tháng Giêng: VOV, Thanh Niên.
//    • Ông Công Ông Táo: VietnamNet, Dân Trí.
//    • Thanh Minh (tại gia): VOV, Znews.
//    • Vu Lan (gia tiên): NLĐ, Tiền Phong.
//    • Trung Thu: VOV, VietnamNet, Dân Trí.
//

import Foundation

private typealias T = VanKhanToken

extension VanKhanLibrary {

    static let festivalTexts: [VanKhanText] = [
        VanKhanText(
            occasionId: "giao-thua",
            body: """
            Nam mô A Di Đà Phật! (3 lần)

            Nam mô Đương Lai Hạ Sinh Di Lặc Tôn Phật.
            Nam mô Đông Phương Giáo Chủ Dược Sư Lưu Ly Quang Vương Phật.
            Nam mô Đức Bồ Tát Quán Thế Âm cứu nạn cứu khổ chúng sinh.

            Con kính lạy chín phương Trời, mười phương Chư Phật, Chư Phật mười phương.
            Con kính lạy Hoàng Thiên, Hậu Thổ, Long Mạch, Táo Quân, chư vị Tôn thần.
            Các cụ tổ tiên nội ngoại họ \(T.familyName), chư vị tiên linh.

            Nay phút giao thừa năm cũ với năm mới.

            Chúng con là: \(T.name)
            Ngụ tại: \(T.address)

            Phút giao thừa vừa điểm, nay theo vận luật, tống cựu nghênh tân, giờ Tý đầu xuân, đón mừng Nguyên đán, tín chủ chúng con thành tâm tu biện hương hoa phẩm vật, nghi lễ cung trần, dâng lên trước án, cúng dàng Phật Thánh, dâng hiến Tôn thần, tiến cúng Tổ tiên, đốt nén tâm hương, dốc lòng bái thỉnh.

            Chúng con kính mời: Ngài Bản cảnh Thành hoàng chư vị Đại vương, ngài Bản xứ Thần linh Thổ địa, ngài Hỷ thần, Phúc đức chính thần, các ngài Ngũ phương, Ngũ thổ, Long mạch, Tài thần, các ngài bản gia Táo phủ thần quân và chư vị thần linh cai quản ở trong xứ này. Cúi xin giáng lâm trước án, thụ hưởng lễ vật.

            Con lại kính mời các cụ tiên linh Cao Tằng Tổ Khảo, Cao Tằng Tổ Tỷ, Bá Thúc Đệ Huynh, Cô Di Tỷ Muội, nội ngoại gia tộc họ \(T.familyName), chư vị hương linh, cúi xin giáng phó linh sàng thụ hưởng lễ vật.

            Tín chủ lại kính mời các vị vong linh tiền chủ, hậu chủ, y thảo phụ mộc ở trong đất này, nhân tiết giao thừa, giáng lâm trước án, chiêm ngưỡng tân xuân, thụ hưởng lễ vật.

            Nguyện cho tín chủ, minh niên khang thái, vạn sự cát tường, bốn mùa được bình an, gia đạo hưng long, thịnh vượng.

            Tâm thành cầu nguyện, lễ bạc tiến dâng, cúi xin chứng giám.

            Nam mô A Di Đà Phật! (3 lần)
            """
        ),

        VanKhanText(
            occasionId: "nguyen-dan",
            body: """
            Nam mô A Di Đà Phật! (3 lần)

            Con lạy chín phương Trời, mười phương chư Phật, chư Phật mười phương.
            Con kính lạy Hoàng thiên, Hậu thổ, chư vị tôn thần.
            Con kính lạy ngài Bản cảnh Thành hoàng, ngài Bản xứ Thổ địa, ngài Bản gia Táo quân cùng chư vị tôn thần.
            Con kính lạy tổ tiên, Hiển khảo, Hiển tỷ, chư vị hương linh.

            Tín chủ (chúng) con là: \(T.name)
            Ngụ tại: \(T.address)

            Hôm nay là ngày mùng 1 tháng Giêng, nhằm ngày Tết Nguyên Đán đầu xuân, giải trừ gió đông lạnh lẽo, hung nghiệt tiêu tan, đón mừng Nguyên Đán xuân thiên, mưa móc thấm nhuần, muôn vật tưng bừng đổi mới. Nơi nơi lễ tiết, chốn chốn tường trình.

            Tín chủ con nhờ ơn đức trời đất, chư vị tôn thần, cù lao tiên tổ, thành tâm sắm lễ, hương, hoa trà quả, thắp nén tâm hương dâng lên trước án.

            Chúng con kính mời: Bản cảnh Thành hoàng chư vị đại vương, ngài Bản xứ Thần linh Thổ địa, ngài Bản gia Táo quân, Ngũ phương, Long mạch, Tài thần. Cúi xin các ngài giáng lâm trước án, chứng giám lòng thành, thụ hưởng lễ vật.

            Chúng con kính mời các cụ Tổ khảo, Tổ tỷ, chư vị hương linh gia tiên nội ngoại họ \(T.familyName), cúi xin thương xót con cháu, linh thiêng hiện về, chứng giám tâm thành, thụ hưởng lễ vật.

            Tín chủ con lại kính mời các vị Tiền chủ, Hậu chủ ngụ tại nhà này, đồng lâm án tiền, đồng lai hâm hưởng, phù hộ cho toàn gia chúng con luôn luôn mạnh khỏe, mọi sự bình an, vạn sự tốt lành, làm ăn phát tài, gia đình hòa thuận.

            Chúng con lễ bạc tâm thành, trước án kính lễ, cúi xin được phù hộ độ trì.

            Nam mô A Di Đà Phật! (3 lần)
            """
        ),

        VanKhanText(
            occasionId: "ram-thang-gieng",
            body: """
            Nam mô A Di Đà Phật! (3 lần)

            Con lạy chín phương Trời, mười phương Chư Phật, Chư Phật mười phương.
            Con kính lạy Hoàng thiên Hậu Thổ chư vị Tôn thần.
            Con kính lạy ngài Bản cảnh Thành hoàng, ngài Bản xứ Thổ địa, ngài Bản gia Táo quân cùng chư vị Tôn thần.
            Con kính lạy Cao Tằng Tổ Khảo, Cao Tằng Tổ Tỷ, Thúc Bá Đệ Huynh, Cô Di, Tỷ Muội họ nội họ ngoại.

            Tín chủ (chúng) con là: \(T.name)
            Ngụ tại: \(T.address)

            Hôm nay là ngày \(T.lunarDate) (tức ngày \(T.solarDate) dương lịch), gặp tiết Nguyên tiêu, tín chủ con lòng thành, sửa sang hương đăng, sắm sanh lễ vật, dâng lên trước án.

            Chúng con kính mời ngài Bản cảnh Thành hoàng chư vị Đại vương, ngài Bản xứ Thần linh Thổ địa, ngài Bản gia Táo quân, Ngũ phương, Long mạch, Tài thần. Cúi xin các ngài linh thiêng nghe thấu lời mời, giáng lâm trước án, chứng giám lòng thành thụ hưởng lễ vật.

            Chúng con kính mời các cụ Tổ Khảo, Tổ Tỷ, chư vị Hương linh gia tiên nội ngoại họ \(T.familyName), nghe lời khẩn cầu, kính mời của con cháu, giáng về chứng giám tâm thành, thụ hưởng lễ vật.

            Tín chủ con lại kính mời ông bà Tiền chủ, Hậu chủ tại gia về hưởng lễ vật, chứng giám lòng thành phù hộ độ trì cho gia chung chúng con được vạn sự tốt lành. Bốn mùa không hạn ách, tám tiết hưởng an bình.

            Chúng con lễ bạc tâm thành, trước án kính lễ, cúi xin được phù hộ độ trì.

            Nam mô A Di Đà Phật! (3 lần)
            """
        ),

        VanKhanText(
            occasionId: "ong-cong-ong-tao",
            body: """
            Nam mô A Di Đà Phật! (3 lần)

            Con lạy chín phương Trời, mười phương Chư Phật, Chư Phật mười phương.

            Con kính lạy ngài Đông trù Tư mệnh Táo phủ Thần quân.

            Tín chủ (chúng) con là: \(T.name)
            Ngụ tại: \(T.address)

            Hôm nay, ngày 23 tháng Chạp tín chủ chúng con thành tâm sắp sửa hương hoa phẩm luật, xiêm hài áo mũ, kính dâng tôn thần. Thắp nén tâm hương tín chủ con thành tâm kính bái.

            Chúng con kính mời ngài Đông trù Tư mệnh Táo phủ Thần quân hiển linh trước án hưởng thụ lễ vật.

            Cúi xin Tôn thần gia ân xá tội cho mọi lỗi lầm trong năm qua gia chủ chúng con sai phạm.

            Xin Tôn thần ban phước lộc, phù hộ toàn gia chúng con, trai gái, già trẻ sức khỏe dồi dào, an khang thịnh vượng, vạn sự tốt lành.

            Chúng con lễ bạc tâm thành, kính lễ cầu xin, mong Tôn thần phù hộ độ trì.

            Nam mô A Di Đà Phật! (3 lần)
            """
        ),

        VanKhanText(
            occasionId: "thanh-minh",
            body: """
            Nam mô A Di Đà Phật! (3 lần)

            Con lạy chín phương Trời, mười phương chư Phật, chư Phật mười phương.

            Con lạy gia tiên tiền tổ, họ hàng nội ngoại hai bên gia tộc họ \(T.familyName).

            Con lạy bà tổ cô ông mãnh, ông bà, cô bé Đỏ, cậu bé Đỏ tại gia.

            Hôm nay là ngày \(T.solarDate).

            Nay con giữ việc phụng thờ tên là \(T.name), sinh tại \(T.address) cùng toàn gia, trước bàn thờ gia tiên cúi đầu bái lễ.

            Kính mời Thổ công Táo quân đồng lai cách cảm.

            Kính dâng lễ bạc: Trầu rượu, trà nước, vàng hương, hoa quả cùng phẩm vật lòng thành nhân dịp tiết Thanh minh, kính mời hương hồn nội ngoại tổ tiên, kỵ, cụ, ông bà, cha mẹ, cô dì chú bác, anh chị em chứng giám và hưởng lễ.

            Con thành tâm thành kính cúi xin gia tiên tiền tổ, bà tổ cô ông mãnh, ông bà… phù hộ độ trì, đề tâm xếp nếp, vuốt ve che chở cho đại gia đình con bình an, thịnh vượng, ba tháng mùa hè chín tháng mùa đông đều mát mẻ, tốt tươi. Điều lành mang lại, điều dữ mang đi cho công việc của gia đình con đều thuận buồm xuôi gió, gặp nhiều may mắn.

            Chúng con kính dâng lễ bạc tâm thành, cúi xin gia tiên chứng minh chứng giám cho lòng thành của toàn thể gia quyến.

            Nam mô A Di Đà Phật! (3 lần)
            """
        ),

        VanKhanText(
            occasionId: "vu-lan",
            body: """
            Nam mô A Di Đà Phật! (3 lần)

            Con lạy chín phương Trời, mười phương Chư Phật, Chư Phật mười phương.

            Con kính lạy tổ tiên nội ngoại và chư vị Hương linh.

            Tín chủ chúng con là: \(T.name)
            Ngụ tại: \(T.address)

            Hôm nay là ngày Rằm tháng Bảy. Nhân gặp tiết Vu Lan vào dịp Trung Nguyên, chúng con nhớ đến tổ tiên ông bà cha mẹ đã sinh thành ra chúng con gây dựng cơ nghiệp, xây đắp nền nhân, khiến nay chúng con được hưởng âm đức.

            Chúng con cảm nghĩ ơn đức cù lao khôn báo, cảm công trời biển khó đền nên tín chủ con sửa sang lễ vật, hương hoa, trà quả, kim ngân vàng bạc, thắp nén tâm hương, thành kính lên các cụ Cao Tằng Tổ Khảo, Cao Tằng Tổ Tỷ, Bá Thúc Đệ Huynh, Cô Di, Tỷ Muội và tất cả các hương hồn trong nội tộc, ngoại tộc của họ \(T.familyName).

            Cúi xin các vị thương xót cháu con, linh thiêng hiện về, chứng giám lòng thành, thụ hưởng lễ vật, phù hộ cho con cháu khỏe mạnh bình an, lộc tài vượng tiến, vạn sự tốt lành, gia đạo hưng long, hướng về chính giáo.

            Chúng con lễ bạc tâm thành, trước án lễ, cúi xin được phù hộ độ trì.

            Nam mô A Di Đà Phật! (3 lần)
            """
        ),

        VanKhanText(
            occasionId: "trung-thu",
            body: """
            Nam mô A Di Đà Phật! (3 lần)

            Con kính lạy Hoàng thiên Hậu Thổ chư vị Tôn thần.

            Con kính lạy ngài Bản cảnh Thành hoàng, ngài Bản xứ Thổ địa, ngài Bản gia Táo quân cùng chư vị Tôn thần.

            Con kính lạy Cao Tằng Tổ Khảo, Cao Tằng Tổ Tỷ, Thúc bá, đệ huynh, cô di, tỷ muội họ nội họ ngoại họ \(T.familyName).

            Tín chủ (chúng) con là: \(T.name)
            Ngụ tại: \(T.address)

            Hôm nay là ngày Rằm tháng Tám gặp tiết Trung Thu, tín chủ chúng con thành tâm sắm lễ, hương hoa trà quả, thắp nén tâm hương dâng lên trước án.

            Chúng con kính mời ngài Bản cảnh Thành hoàng Chư vị Đại Vương, ngài Bản xứ Thần linh Thổ địa, ngài Bản gia Táo quân, Ngũ phương, Long mạch, Tài thần. Cúi xin các ngài giáng lâm trước án, chứng giám lòng thành thụ hưởng lễ vật.

            Chúng con kính mời các cụ Tổ Khảo, Tổ Tỷ, chư vị hương linh gia tiên nội ngoại họ \(T.familyName), cúi xin thương xót con cháu linh thiêng hiện về, chứng giám tâm thành, thụ hưởng lễ vật.

            Tín chủ con lại kính mời các vị Tiền chủ, Hậu chủ ngụ tại nhà này, đất này đồng lâm án tiền, đồng lai hâm hưởng.

            Xin các ngài độ cho chúng con thân cung khang thái, bản mệnh bình an, bốn mùa không hạn ách, tám tiết hưởng vinh quang thịnh vượng.

            Chúng con lễ bạc tâm thành, trước án kính lễ, cúi xin được phù hộ độ trì.

            Nam mô A Di Đà Phật! (3 lần)
            """
        ),
    ]
}
