//
//  VanKhanTexts+Anniversary.swift
//  lich-plus
//
//  Template body for giỗ (death anniversary - Cát Kỵ). Placeholders are typed via
//  `VanKhanToken` interpolation — see `VanKhanTexts+Monthly.swift` for the pattern.
//
//  Source: "Văn khấn cổ truyền Việt Nam" – NXB Văn hóa Thông tin.
//  Đối chiếu: VietnamNet, lichvansu.wap.vn.
//

import Foundation

private typealias T = VanKhanToken

extension VanKhanLibrary {

    static let anniversaryTexts: [VanKhanText] = [
        VanKhanText(
            occasionId: "gio",
            body: """
            Nam mô A Di Đà Phật! (3 lần)

            Con lạy chín phương Trời, mười phương Chư Phật, Chư Phật mười phương.

            Con kính lạy Đức Hoàng Thiên Hậu Thổ chư vị Tôn thần.

            Con kính lạy ngài Đông Trù Tư mệnh Táo phủ Thần Quân.

            Con kính lạy các ngài Thần linh, Thổ địa cai quản trong xứ này.

            Con kính lạy Tổ Tiên nội ngoại họ \(T.familyName).

            Tín chủ (chúng) con là: \(T.name)
            Ngụ tại: \(T.address)

            Hôm nay là ngày \(T.lunarDate) (nhằm ngày \(T.solarDate) dương lịch), là chính ngày Cát Kỵ của \(T.deceasedRelation) chúng con là \(T.deceasedName).

            Thiết nghĩ \(T.deceasedRelation) vắng xa trần thế, không thấy âm dung.

            Năm qua tháng lại, ngày húy lâm. Ơn võng cực xem bằng trời biển, nghĩa sinh thành không lúc nào quên. Càng nhớ công ơn gây cơ tạo nghiệp bao nhiêu, càng cảm thâm tình, không bề giãi tỏ. Hôm nay chúng con và toàn gia con cháu thành tâm sắm lễ, quả cau, lá trầu, hương hoa trà quả, thắp nén tâm hương dâng lên trước án thành khẩn kính mời: \(T.deceasedName).

            Cúi xin linh thiêng giáng về linh sàng, chứng giám lòng thành, thụ hưởng lễ vật, độ cho con cháu an ninh khang thái, vạn sự tốt lành, gia cảnh hưng long thịnh vượng.

            Con lại xin kính mời các vị Tổ Tiên nội ngoại, Tổ Khảo, Tổ Tỷ, Bá Thúc, Huynh Đệ, Cô Di, và toàn thể các Hương linh gia tiên đồng lai hâm hưởng.

            Tín chủ con lại xin kính mời ngài Thổ Công, Táo Quân và chư vị Linh thần đồng lai giám cách thượng hưởng.

            Tín chủ lại mời các vị vong linh Tiền chủ, Hậu chủ nhà này, đất này cùng tới hâm hưởng.

            Chúng con lễ bạc tâm thành, cúi xin được phù hộ độ trì.

            Nam mô A Di Đà Phật! (3 lần)
            """
        ),
    ]
}
