//
//  VanKhanTexts+Family.swift
//  lich-plus
//
//  Template bodies for family events: cưới hỏi, nhập trạch, đầy tháng, thôi nôi.
//  Placeholders are typed via `VanKhanToken` interpolation.
//
//  Sources (per "Văn khấn cổ truyền Việt Nam" – NXB Văn hóa Thông tin):
//    • Cưới hỏi (báo cáo gia tiên): các trang chuyên văn khấn tổng hợp (cuthongthai, doctailieu, scr.vn).
//    • Nhập trạch: VietnamNet/Infonet (2 nguồn đối chiếu) — gồm bài Thần linh + Yết Gia tiên.
//    • Đầy tháng / Thôi nôi: dothocungtamlinh, dothoduchiep, vanxuanam (đối chiếu nhiều nguồn).
//

import Foundation

private typealias T = VanKhanToken

extension VanKhanLibrary {

    static let familyTexts: [VanKhanText] = [
        VanKhanText(
            occasionId: "cuoi-hoi",
            body: """
            Nam mô A Di Đà Phật! (3 lần)

            Con lạy chín phương Trời, mười phương Chư Phật, Chư Phật mười phương.

            Con kính lạy Hoàng thiên, Hậu Thổ, chư vị Tôn thần.

            Con kính lạy ngài Bản cảnh Thành hoàng, ngài Bản xứ Thổ địa, ngài Bản gia Táo quân cùng chư vị Tôn thần.

            Con kính lạy tổ tiên họ \(T.familyName), chư vị Hương linh.

            Tín chủ (chúng) con là: \(T.name)
            Ngụ tại: \(T.address)

            Hôm nay là ngày \(T.lunarDate), tức ngày \(T.solarDate).

            Tín chủ chúng con có con trai (con gái) kết duyên cùng. Nay thủ tục hôn lễ đã thành. Xin kính dâng lễ vật, dâng lên trước án.

            Kính lạy trước linh tọa Ngũ tự Gia thần chư vị Tôn linh, trước linh bài liệt vị Gia tiên, trước Phúc Tổ Di Lai, ông Tơ bà Nguyệt. Xin kính cẩn khẩn cầu:

            Phúc tổ di lai,
            Sinh trai có vợ (nếu là nhà trai),
            Sinh gái có chồng (nếu là nhà gái),
            Lễ mọn kính dâng,
            Duyên lành gặp gỡ,
            Giai lão trăm năm,
            Vững bền hai họ,
            Nghi thất nghi gia,
            Có con có của,
            Cầm sắt giao hòa,
            Trông nhờ phúc Tổ.

            Chúng con lễ bạc tâm thành, xin được phù hộ độ trì.

            Nam mô A Di Đà Phật! (3 lần)
            """
        ),

        VanKhanText(
            occasionId: "nhap-trach",
            body: """
            Nam mô A Di Đà Phật! (3 lần)

            ── Phần 1: Văn khấn Thần linh ──

            Con lạy chín phương Trời, mười phương Chư Phật, Chư Phật mười phương.

            Con kính lạy Hoàng Thiên Hậu Thổ chư vị Tôn thần.

            Con kính lạy các ngài Thần linh bản xứ cai quản trong khu vực này.

            Tín chủ con là: \(T.name)

            Hôm nay là ngày lành tháng tốt, tín chủ con thành tâm sắm lễ, quả cau lá trầu, hương hoa trà quả, thắp nén tâm hương dâng lên trước án. Trước bản tọa chư vị Tôn thần, tín chủ con kính cẩn tâu trình:

            Các vị Thần linh,
            Thông minh chính trực,
            Giữ ngôi tam thai,
            Nắm quyền tạo hóa,
            Thể đức hiếu sinh,
            Phù hộ dân lành,
            Bảo vệ sinh linh,
            Nêu cao chính đạo.

            Nay gia đình chúng con hoàn tất tân gia, chọn được ngày lành dọn đến cư ngụ, phần sài nhóm lửa, kính lễ khánh hạ.

            Cầu xin chư vị Thần linh cho chúng con được nhập vào nhà mới tại: \(T.address), lập bát nhang thờ chư vị Tôn thần.

            Chúng con xin phép chư vị Tôn thần cho rước vong linh gia tiên chúng con về ở nơi này để thờ phụng.

            Chúng con cầu xin chư vị Thần linh gia ân tác phúc, độ cho gia quyến chúng con an ninh, khang thái, làm ăn tiến tới, tài lộc dồi dào, vạn sự như ý, vạn điều tốt lành.

            Chúng con lại mời các vong linh Tiền chủ, Hậu chủ ở trong nhà này, đất này xin cùng về đây chiêm ngưỡng Tôn thần, thụ hưởng lễ vật, phù hộ cho chúng con sức khỏe dồi dào, an khang, thịnh vượng.

            Chúng con lễ bạc tâm thành, trước án kính lễ, cúi xin được phù hộ độ trì.

            ── Phần 2: Văn khấn cáo yết Gia tiên ──

            Kính lạy Tiên nội ngoại họ \(T.familyName).

            Gia đình chúng con mới dọn đến đây là: \(T.address).

            Chúng con thành tâm sắm lễ, quả cau lá trầu, hương hoa trà quả, thắp nén tâm hương dâng lên trước ban thờ cụ nội ngoại gia tiên.

            Nhờ hồng phúc tổ tiên, ông bà cha mẹ, chúng con đã tạo lập được ngôi nhà mới.

            Nhân chọn được ngày lành tháng tốt, thiết lập án thờ, kê giường nhóm lửa, kính lễ khánh hạ.

            Cúi xin các cụ, ông bà cùng chư vị Hương linh nội ngoại họ \(T.familyName) thương xót con cháu, chứng giám lòng thành, giáng phó linh sàng, thụ hưởng lễ vật, phù hộ độ trì cho chúng con lộc tài vượng tiến, gia đạo hưng long, cháu con được bình an mạnh khỏe.

            Chúng con lễ bạc tâm thành, trước án kính lễ, cúi xin được phù hộ độ trì.

            Nam mô A Di Đà Phật! (3 lần)
            """
        ),

        VanKhanText(
            occasionId: "day-thang",
            body: """
            Nam mô A Di Đà Phật! (3 lần)

            Con kính lạy Đệ nhất Thiên tỷ đại tiên chúa.
            Con kính lạy Đệ nhị Thiên đế đại tiên chúa.
            Con kính lạy Đệ tam Tiên Mụ đại tiên chúa.
            Con kính lạy Thập nhị bộ Tiên Nương.
            Con kính lạy Tam thập lục cung chư vị Tiên Nương.

            Hôm nay là ngày đầy tháng của cháu.

            Vợ chồng con là \(T.name), sinh được con (trai/gái) đặt tên là \(T.childName).

            Chúng con ngụ tại: \(T.address)

            Nay nhân ngày đầy tháng, chúng con thành tâm sửa biện hương hoa lễ vật và các thứ cúng dâng bày lên trước án, trước bàn tọa chư vị Tôn thần kính cẩn tâu trình:

            Nhờ ơn thập phương chư Phật, chư vị Thánh hiền, chư vị Tiên Bà, các đấng Thần linh, Thổ Công địa mạch, Thổ Địa chính thần, Tiên tổ nội ngoại, cho con sinh ra cháu tên là \(T.childName) được mẹ tròn con vuông.

            Chúng con thành tâm cúi xin chư vị Tiên Bà, chư vị Tôn thần giáng lâm trước án, chứng giám lòng thành, thụ hưởng lễ vật, phù hộ độ trì, vuốt ve che chở cho cháu được ăn ngoan, ngủ yên, hay ăn chóng lớn, vô bệnh vô tật, vô tai vô ương, vô hạn vô ách. Phù hộ cho cháu bé được tươi đẹp, thông minh, sáng láng, thân mệnh bình yên, cường tráng, kiếp kiếp được hưởng vinh hoa phú quý.

            Gia đình chúng con được phúc thọ an khang, nhân lành nảy nở, nghiệp dữ tiêu tan, bốn mùa không hạn ách nghĩ lo, tám tiết hưởng vinh quang thịnh vượng.

            Xin thành tâm đỉnh lễ, cúi xin được chứng giám lòng thành.

            Nam mô A Di Đà Phật! (3 lần)
            """
        ),

        VanKhanText(
            occasionId: "thoi-noi",
            body: """
            Nam mô A Di Đà Phật! (3 lần)

            Con kính lạy Đệ nhất Thiên tỷ đại tiên chúa.
            Con kính lạy Đệ nhị Thiên đế đại tiên chúa.
            Con kính lạy Đệ tam Thiên Mụ đại tiên chúa.
            Con kính lạy Tam thập lục cung chư vị Tiên Nương.

            Hôm nay là ngày Thôi Nôi (tròn một tuổi) của cháu.

            Vợ chồng con là \(T.name), sinh được con (trai/gái) đặt tên là \(T.childName).

            Chúng con ngụ tại: \(T.address)

            Nay nhân ngày đầy năm, chúng con thành tâm sửa biện hương hoa lễ vật và các thứ cúng dâng bày lên trước án, trước bàn tọa chư vị Tôn thần kính cẩn tấu trình:

            Nhờ ơn thập phương chư Phật, chư vị Thánh hiền, chư vị Tiên Bà, các đấng Thần linh, Thổ công địa mạch, Thổ địa chính thần, Tiên tổ nội ngoại, cho con sinh ra cháu tên là \(T.childName) được mẹ tròn con vuông.

            Cúi xin chư vị Tiên Bà, chư vị Tôn thần giáng lâm trước án, chứng giám lòng thành thụ hưởng lễ vật, phù hộ độ trì, vuốt ve che chở cho cháu được ăn ngon, ngủ yên, hay ăn chóng lớn, vô bệnh vô tật, vô ương, vô hạn, vô ách, phù hộ cho cháu bé được tươi đẹp, thông minh, sáng láng, thân mệnh bình yên, cường tráng, kiếp kiếp được hưởng vinh hoa phú quý.

            Gia đình con được phúc thọ an khang, nhân lành nảy nở, nghiệp dữ tiêu tan, bốn mùa không hạn ách nghĩ lo.

            Xin thành tâm đỉnh lễ, cúi xin được chứng giám lòng thành.

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
