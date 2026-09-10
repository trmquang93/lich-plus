//
//  HexagramLibrary.swift
//  lich-plus
//
//  64 hexagram summaries — short original paraphrases, not book excerpts.
//

import Foundation

enum HexagramLibrary {
    private static let entries: [Hexagram] = [
        Hexagram(id: 1, pattern: "111111", name: String(localized: "Càn / Kiên"), summary: String(localized: "Strong beginnings and steady effort. Act with integrity; avoid forcing outcomes.")),
        Hexagram(id: 2, pattern: "000000", name: String(localized: "Khôn / Thuần"), summary: String(localized: "Receive and support others. Patience and humility bring progress now.")),
        Hexagram(id: 3, pattern: "100010", name: String(localized: "Truân / Khó khăn"), summary: String(localized: "Early obstacles are normal. Seek help, move step by step, do not rush.")),
        Hexagram(id: 4, pattern: "010001", name: String(localized: "Mông / Non nớt"), summary: String(localized: "You may lack clarity — ask a trusted teacher. Learn before deciding.")),
        Hexagram(id: 5, pattern: "111010", name: String(localized: "Nhu / Chờ"), summary: String(localized: "Wait with purpose. Prepare while timing ripens; forcing action backfires.")),
        Hexagram(id: 6, pattern: "010111", name: String(localized: "Tụng / Tranh chấp"), summary: String(localized: "Conflict costs more than compromise. Seek fair middle ground early.")),
        Hexagram(id: 7, pattern: "010000", name: String(localized: "Sư / Quân"), summary: String(localized: "Discipline and clear roles matter. Lead with order, not fear.")),
        Hexagram(id: 8, pattern: "000010", name: String(localized: "Tỷ / Gần gũi"), summary: String(localized: "Alliance and trust build strength. Choose companions carefully.")),
        Hexagram(id: 9, pattern: "111011", name: String(localized: "Tiểu Súc"), summary: String(localized: "Small gains accumulate. Restrain spending and temper; progress is gradual.")),
        Hexagram(id: 10, pattern: "110111", name: String(localized: "Lý / Đi"), summary: String(localized: "Walk carefully on thin ice. Courtesy and caution keep you safe.")),
        Hexagram(id: 11, pattern: "111000", name: String(localized: "Thái / Thông"), summary: String(localized: "Heaven and earth harmonize. A favorable season for cooperation.")),
        Hexagram(id: 12, pattern: "000111", name: String(localized: "Bĩ / Tắc"), summary: String(localized: "Blockage — withdraw from noise. Protect values; wait for better air.")),
        Hexagram(id: 13, pattern: "101111", name: String(localized: "Đồng Nhân"), summary: String(localized: "Open hearts unite people. Shared purpose beats solo ambition.")),
        Hexagram(id: 14, pattern: "111101", name: String(localized: "Đại Hữu"), summary: String(localized: "Abundance with responsibility. Share generously; pride invites loss.")),
        Hexagram(id: 15, pattern: "001000", name: String(localized: "Khiêm / Nhún nhường"), summary: String(localized: "Modesty draws respect. Lower the ego; success follows naturally.")),
        Hexagram(id: 16, pattern: "000100", name: String(localized: "Dự / Hân hoan"), summary: String(localized: "Joy in movement — rally others kindly. Enthusiasm needs direction.")),
        Hexagram(id: 17, pattern: "100110", name: String(localized: "Tùy / Theo"), summary: String(localized: "Adapt to the moment. Following wise counsel beats stubborn solo plans.")),
        Hexagram(id: 18, pattern: "011001", name: String(localized: "Cổ / Sửa"), summary: String(localized: "Repair what decayed. Face old mistakes; renewal needs honest work.")),
        Hexagram(id: 19, pattern: "110000", name: String(localized: "Lâm"), summary: String(localized: "Approach with sincerity. Influence grows when you serve, not dominate.")),
        Hexagram(id: 20, pattern: "000011", name: String(localized: "Quan / Quan sát"), summary: String(localized: "Step back and observe patterns. Insight comes from watching, not rushing.")),
        Hexagram(id: 21, pattern: "100101", name: String(localized: "Phệ Hạp"), summary: String(localized: "Clear obstacles firmly but fairly. Justice restores flow.")),
        Hexagram(id: 22, pattern: "101001", name: String(localized: "Bí / Trang điểm"), summary: String(localized: "Form follows substance. Beauty helps, but inner truth must lead.")),
        Hexagram(id: 23, pattern: "000001", name: String(localized: "Bác / Tan vỡ"), summary: String(localized: "Something is falling away. Let go of what cannot stand; protect essentials.")),
        Hexagram(id: 24, pattern: "100000", name: String(localized: "Phục / Quay lại"), summary: String(localized: "Return to roots. A cycle turns back — forgive and begin again.")),
        Hexagram(id: 25, pattern: "100111", name: String(localized: "Vô Vong"), summary: String(localized: "Innocent intent matters. Act without hidden motive; accidents teach humility.")),
        Hexagram(id: 26, pattern: "111001", name: String(localized: "Đại Súc"), summary: String(localized: "Restrain great power. Store energy; study before the next push.")),
        Hexagram(id: 27, pattern: "100001", name: String(localized: "Di / Nuôi dưỡng"), summary: String(localized: "Nourish body and speech. What you feed grows — choose wisely.")),
        Hexagram(id: 28, pattern: "011110", name: String(localized: "Đại Quá"), summary: String(localized: "Excess weight on a beam. Support others; avoid heroic overload.")),
        Hexagram(id: 29, pattern: "010010", name: String(localized: "Khảm / Hiểm"), summary: String(localized: "Repeated danger — stay centered. Honesty and calm carry you through.")),
        Hexagram(id: 30, pattern: "101101", name: String(localized: "Ly / Sáng"), summary: String(localized: "Clarity like fire. Attach to what is right; avoid empty spectacle.")),
        Hexagram(id: 31, pattern: "001110", name: String(localized: "Hàm / Cảm"), summary: String(localized: "Mutual attraction. Gentle influence works; pressure repels.")),
        Hexagram(id: 32, pattern: "011100", name: String(localized: "Hằng / Bền"), summary: String(localized: "Endurance through change. Keep commitments flexible yet steady.")),
        Hexagram(id: 33, pattern: "001111", name: String(localized: "Độn / Ẩn"), summary: String(localized: "Strategic retreat. Step back to preserve strength for later.")),
        Hexagram(id: 34, pattern: "111100", name: String(localized: "Đại Tráng"), summary: String(localized: "Great vigor — use power ethically. Bold moves need restraint.")),
        Hexagram(id: 35, pattern: "000101", name: String(localized: "Tấn / Tiến"), summary: String(localized: "Advance like sunrise. Recognition comes from steady improvement.")),
        Hexagram(id: 36, pattern: "101000", name: String(localized: "Minh Di"), summary: String(localized: "Hide light in hardship. Protect your inner truth until safer days.")),
        Hexagram(id: 37, pattern: "101011", name: String(localized: "Gia Nhân"), summary: String(localized: "Family order and warmth. Roles and kindness keep the home strong.")),
        Hexagram(id: 38, pattern: "110101", name: String(localized: "Khuê / Lìa"), summary: String(localized: "Opposites meet awkwardly. Respect differences; small agreements help.")),
        Hexagram(id: 39, pattern: "001010", name: String(localized: "Kiển / Cản"), summary: String(localized: "Obstruction ahead. Pause, seek advice, take the longer safe path.")),
        Hexagram(id: 40, pattern: "010100", name: String(localized: "Giải / Giải thoát"), summary: String(localized: "Relief after tension. Forgive and move; do not reopen old wounds.")),
        Hexagram(id: 41, pattern: "110001", name: String(localized: "Sun / Giảm"), summary: String(localized: "Less can be more. Trim excess; sincerity beats lavish display.")),
        Hexagram(id: 42, pattern: "100011", name: String(localized: "Ích / Tăng"), summary: String(localized: "Increase for the worthy. Invest in learning and generous action.")),
        Hexagram(id: 43, pattern: "111110", name: String(localized: "Quải / Quyết"), summary: String(localized: "Decisive break-through. Speak truth clearly; avoid cruelty.")),
        Hexagram(id: 44, pattern: "011111", name: String(localized: "Cấu / Gặp"), summary: String(localized: "Sudden encounter. Stay alert to influence — not every offer is benign.")),
        Hexagram(id: 45, pattern: "000110", name: String(localized: "Tụy / Họp"), summary: String(localized: "Gathering together. Shared ritual and purpose unite the group.")),
        Hexagram(id: 46, pattern: "011000", name: String(localized: "Thăng / Lên"), summary: String(localized: "Steady ascent. Small sincere steps rise like a growing tree.")),
        Hexagram(id: 47, pattern: "010110", name: String(localized: "Khốn / Kiệt"), summary: String(localized: "Exhaustion — simplify. Accept limits; inner worth remains.")),
        Hexagram(id: 48, pattern: "011010", name: String(localized: "Tỉnh / Giếng"), summary: String(localized: "Deep well of renewal. Return to basics; share resources fairly.")),
        Hexagram(id: 49, pattern: "101110", name: String(localized: "Cách / Đổi"), summary: String(localized: "Revolution when the old no longer serves. Change with clear timing.")),
        Hexagram(id: 50, pattern: "011101", name: String(localized: "Đỉnh / Vững"), summary: String(localized: "Steady vessel — culture and nourishment. Transform with care.")),
        Hexagram(id: 51, pattern: "100100", name: String(localized: "Chấn / Sấm"), summary: String(localized: "Shock wakes you up. After surprise, regain composure and act cleanly.")),
        Hexagram(id: 52, pattern: "001001", name: String(localized: "Cấn / Dừng"), summary: String(localized: "Still the mind. Stop at the right moment; calm reveals the next step.")),
        Hexagram(id: 53, pattern: "001011", name: String(localized: "Tiệm / Dần"), summary: String(localized: "Gradual progress like marriage. Trust the slow path; haste harms.")),
        Hexagram(id: 54, pattern: "110100", name: String(localized: "Quy Muội"), summary: String(localized: "Improper position — adapt humbly. Avoid forcing status you lack.")),
        Hexagram(id: 55, pattern: "101100", name: String(localized: "Phong / Phong đăng"), summary: String(localized: "Peak abundance — share the light. Fullness fades; stay generous.")),
        Hexagram(id: 56, pattern: "001101", name: String(localized: "Lữ / Lữ hành"), summary: String(localized: "Travel lightly. Respect local ways; home is where the heart rests.")),
        Hexagram(id: 57, pattern: "011011", name: String(localized: "Tốn / Nhẹ"), summary: String(localized: "Gentle penetration. Soft persistence shapes what force cannot.")),
        Hexagram(id: 58, pattern: "110110", name: String(localized: "Đoài / Vui"), summary: String(localized: "Joyful exchange. Speak honestly; shared laughter heals.")),
        Hexagram(id: 59, pattern: "010011", name: String(localized: "Hoán / Tan"), summary: String(localized: "Dissolve barriers. Open communication melts distrust.")),
        Hexagram(id: 60, pattern: "110010", name: String(localized: "Tiết / Giới"), summary: String(localized: "Healthy limits. Measure and rhythm protect long-term success.")),
        Hexagram(id: 61, pattern: "110011", name: String(localized: "Trung Fu"), summary: String(localized: "Inner truth resonates. Sincerity reaches others even across distance.")),
        Hexagram(id: 62, pattern: "001100", name: String(localized: "Tiểu Quá"), summary: String(localized: "Small excess — stay modest. Do not overreach; detail matters now.")),
        Hexagram(id: 63, pattern: "101010", name: String(localized: "Ký Tế"), summary: String(localized: "Almost complete — guard the finish. Order now; vigilance prevents slip.")),
        Hexagram(id: 64, pattern: "010101", name: String(localized: "Vị Tế"), summary: String(localized: "Not yet finished. Stay attentive through the last steps; chaos before calm.")),
    ]

    private static let byPattern: [String: Hexagram] = Dictionary(
        uniqueKeysWithValues: entries.map { ($0.pattern, $0) }
    )

    static func hexagram(forPattern pattern: String) -> Hexagram? {
        byPattern[pattern]
    }

    static var all: [Hexagram] { entries }
}
