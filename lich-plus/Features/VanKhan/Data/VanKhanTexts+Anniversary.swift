//
//  VanKhanTexts+Anniversary.swift
//  lich-plus
//
//  Template body for giỗ (death anniversary).
//  Tokens: {name}, {address}, {lunarDate}, {solarDate},
//  {deceasedRelation}, {deceasedName}.
//
//  TODO: Replace stub text with vetted Vietnamese sources before shipping.
//

import Foundation

extension VanKhanLibrary {

    static let anniversaryTexts: [VanKhanText] = [
        VanKhanText(
            occasionId: "gio",
            body: """
            Nam mô A Di Đà Phật! (3 lần)

            Con kính lạy chín phương Trời, mười phương Chư Phật, Chư Phật mười phương.
            Con kính lạy Đức Đương cảnh Thành Hoàng chư vị Đại Vương.
            Con kính lạy ngài Đông Trù Tư Mệnh Táo Phủ Thần Quân.
            Con kính lạy chư vị Tổ tiên nội ngoại, Hiển khảo, Hiển tỷ, chư vị Hương linh.

            Tín chủ con là: {name}
            Ngụ tại: {address}

            Hôm nay là ngày {lunarDate} (nhằm ngày {solarDate}), nhân ngày giỗ của {deceasedRelation} {deceasedName}, tín chủ con thành tâm sắm sửa hương hoa, lễ vật, trà quả kính dâng trước án.

            [TODO: nội dung khấn ngày giỗ — tra cứu nguồn chính thống]

            Cúi xin hương linh {deceasedRelation} {deceasedName} chứng giám lòng thành, phù hộ cho con cháu mạnh khoẻ, gia đạo bình an.

            Nam mô A Di Đà Phật! (3 lần)
            """
        ),
    ]
}
