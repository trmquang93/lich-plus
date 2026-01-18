//
//  GreetingModels.swift
//  lich-plus
//
//  Created by Claude on 17/01/26.
//

import Foundation

// MARK: - Recipient Type

/// Types of recipients for greeting messages
enum RecipientType: String, CaseIterable, Identifiable {
    case grandparents = "grandparents"
    case parents = "parents"
    case boss = "boss"
    case colleagues = "colleagues"
    case teachers = "teachers"
    case friends = "friends"
    case partner = "partner"
    case children = "children"

    var id: String { rawValue }

    /// Vietnamese display name
    var displayName: String {
        switch self {
        case .grandparents: return "Ông bà"
        case .parents: return "Bố mẹ"
        case .boss: return "Sếp"
        case .colleagues: return "Đồng nghiệp"
        case .teachers: return "Thầy cô"
        case .friends: return "Bạn bè"
        case .partner: return "Người yêu"
        case .children: return "Con cháu"
        }
    }

    /// Icon for each recipient type
    var icon: String {
        switch self {
        case .grandparents: return "figure.2.and.child.holdinghands"
        case .parents: return "figure.2"
        case .boss: return "briefcase.fill"
        case .colleagues: return "person.3.fill"
        case .teachers: return "graduationcap.fill"
        case .friends: return "person.2.fill"
        case .partner: return "heart.fill"
        case .children: return "face.smiling.fill"
        }
    }
}

// MARK: - Greeting Tone

/// Tone/style for greeting messages
enum GreetingTone: String, CaseIterable, Identifiable {
    case formal = "formal"
    case casual = "casual"
    case funny = "funny"
    case romantic = "romantic"

    var id: String { rawValue }

    /// Vietnamese display name
    var displayName: String {
        switch self {
        case .formal: return "Trang trọng"
        case .casual: return "Thân mật"
        case .funny: return "Vui vẻ"
        case .romantic: return "Lãng mạn"
        }
    }

    /// Icon for each tone
    var icon: String {
        switch self {
        case .formal: return "text.quote"
        case .casual: return "hand.wave.fill"
        case .funny: return "face.smiling.fill"
        case .romantic: return "heart.fill"
        }
    }
}

// MARK: - Greeting Occasion

/// Special occasions for greetings
enum GreetingOccasion: String, CaseIterable, Identifiable {
    case tet = "tet"
    case birthday = "birthday"
    case wedding = "wedding"
    case newYear = "new_year"
    case womensDay = "womens_day"
    case teachersDay = "teachers_day"

    var id: String { rawValue }

    /// Vietnamese display name
    var displayName: String {
        switch self {
        case .tet: return "Tết Nguyên Đán"
        case .birthday: return "Sinh nhật"
        case .wedding: return "Đám cưới"
        case .newYear: return "Năm mới dương lịch"
        case .womensDay: return "Ngày 8/3"
        case .teachersDay: return "Ngày Nhà giáo"
        }
    }

    /// Icon for each occasion
    var icon: String {
        switch self {
        case .tet: return "🧧"
        case .birthday: return "🎂"
        case .wedding: return "💒"
        case .newYear: return "🎉"
        case .womensDay: return "🌷"
        case .teachersDay: return "📚"
        }
    }

    /// Zodiac animal for Tết (returns current year's animal)
    var tetZodiacAnimal: String? {
        guard self == .tet else { return nil }
        let year = Calendar.current.component(.year, from: Date())
        return Self.zodiacAnimal(for: year)
    }

    /// Get zodiac animal for a given year
    static func zodiacAnimal(for year: Int) -> String {
        let animals = ["Tý", "Sửu", "Dần", "Mão", "Thìn", "Tỵ", "Ngọ", "Mùi", "Thân", "Dậu", "Tuất", "Hợi"]
        let animalEmojis = ["🐀", "🐂", "🐅", "🐇", "🐉", "🐍", "🐴", "🐐", "🐒", "🐓", "🐕", "🐖"]
        let index = (year - 4) % 12
        return "\(animalEmojis[index]) \(animals[index])"
    }

    /// Get Can-Chi for a given year
    static func canChi(for year: Int) -> String {
        let can = ["Giáp", "Ất", "Bính", "Đinh", "Mậu", "Kỷ", "Canh", "Tân", "Nhâm", "Quý"]
        let chi = ["Tý", "Sửu", "Dần", "Mão", "Thìn", "Tỵ", "Ngọ", "Mùi", "Thân", "Dậu", "Tuất", "Hợi"]
        let canIndex = (year - 4) % 10
        let chiIndex = (year - 4) % 12
        return "\(can[canIndex]) \(chi[chiIndex])"
    }
}

// MARK: - Greeting Request

/// Request model for generating a greeting
struct GreetingRequest {
    let recipientType: RecipientType
    let tone: GreetingTone
    let occasion: GreetingOccasion
    let recipientName: String?
    let additionalInfo: String?
    let year: Int

    init(
        recipientType: RecipientType,
        tone: GreetingTone,
        occasion: GreetingOccasion = .tet,
        recipientName: String? = nil,
        additionalInfo: String? = nil,
        year: Int = Calendar.current.component(.year, from: Date())
    ) {
        self.recipientType = recipientType
        self.tone = tone
        self.occasion = occasion
        self.recipientName = recipientName
        self.additionalInfo = additionalInfo
        self.year = year
    }
}

// MARK: - Generated Greeting

/// Model for a generated greeting message
struct GeneratedGreeting: Identifiable, Equatable {
    let id: UUID
    let text: String
    let request: GreetingRequest
    let createdAt: Date

    init(text: String, request: GreetingRequest) {
        self.id = UUID()
        self.text = text
        self.request = request
        self.createdAt = Date()
    }

    static func == (lhs: GeneratedGreeting, rhs: GeneratedGreeting) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Sample Greetings (Offline Fallback)

/// Pre-defined greeting templates for offline use
struct SampleGreetings {

    /// Get a random sample greeting for a request
    static func randomGreeting(for request: GreetingRequest) -> String {
        let templates = getTemplates(for: request)
        let template = templates.randomElement() ?? templates[0]
        return formatTemplate(template, with: request)
    }

    private static func getTemplates(for request: GreetingRequest) -> [String] {
        let canChi = GreetingOccasion.canChi(for: request.year)
        let zodiac = GreetingOccasion.zodiacAnimal(for: request.year) ?? ""

        switch (request.recipientType, request.tone) {
        // Grandparents
        case (.grandparents, .formal):
            return [
                "Cháu kính chúc Ông Bà năm \(canChi) sức khỏe dồi dào, trường thọ bách niên, vạn sự như ý. Mong Ông Bà luôn vui khỏe để con cháu được sum vầy mỗi dịp Tết!",
                "Nhân dịp Tết \(canChi), cháu kính chúc Ông Bà an khang thịnh vượng, phúc lộc đầy nhà, sống lâu trăm tuổi!",
                "Kính chúc Ông Bà năm mới \(zodiac) mạnh khỏe, bình an, gia đình hạnh phúc, con cháu thảo hiền!"
            ]
        case (.grandparents, .casual):
            return [
                "Chúc Ông Bà năm mới khỏe mạnh, vui vẻ! Cháu thương Ông Bà nhiều lắm ạ! 🧧",
                "Ông Bà ơi, Tết \(canChi) rồi! Chúc Ông Bà luôn khỏe để cháu được về thăm hoài nha!",
                "Happy New Year Ông Bà! Năm \(zodiac) chúc Ông Bà khỏe re, vui vẻ! 🎊"
            ]

        // Parents
        case (.parents, .formal):
            return [
                "Con kính chúc Bố Mẹ năm \(canChi) sức khỏe dồi dào, vạn sự như ý. Cảm ơn Bố Mẹ đã luôn yêu thương và chở che cho con!",
                "Nhân dịp xuân \(canChi), con kính chúc Bố Mẹ an khang thịnh vượng, gia đình hạnh phúc, công việc thuận lợi!",
                "Năm \(zodiac), con chúc Bố Mẹ sức khỏe bình an, mọi điều tốt đẹp, luôn vui vẻ bên con cháu!"
            ]
        case (.parents, .casual):
            return [
                "Bố Mẹ ơi, Happy New Year! Chúc Bố Mẹ năm mới khỏe mạnh, vui vẻ! Con yêu Bố Mẹ! ❤️",
                "Tết \(canChi) rồi! Chúc Bố Mẹ năm mới phát tài phát lộc, khỏe mạnh, hạnh phúc nha!",
                "Năm \(zodiac) chúc Bố Mẹ luôn trẻ khỏe, vui tươi! Con sẽ cố gắng để Bố Mẹ tự hào! 🧧"
            ]

        // Boss
        case (.boss, .formal):
            return [
                "Kính chúc Anh/Chị năm \(canChi) sức khỏe dồi dào, công việc thuận lợi, vạn sự hanh thông!",
                "Nhân dịp Tết \(canChi), kính chúc Sếp một năm mới thành công rực rỡ, mọi dự án đều thuận buồm xuôi gió!",
                "Chúc Anh/Chị năm \(zodiac) đại cát đại lợi, sự nghiệp thăng tiến, gia đình hạnh phúc!"
            ]
        case (.boss, .casual):
            return [
                "Chúc Sếp năm mới \(canChi) vui vẻ, công việc suôn sẻ! Cảm ơn Sếp đã hỗ trợ em trong năm qua! 🎉",
                "Happy New Year Sếp! Năm \(zodiac) chúc Sếp khỏe mạnh, thành công! 🧧",
                "Tết \(canChi) rồi Sếp ơi! Chúc Sếp năm mới phát tài, công ty phát triển!"
            ]

        // Colleagues
        case (.colleagues, .formal):
            return [
                "Chúc các Anh/Chị năm \(canChi) sức khỏe, công việc thuận lợi, gia đình hạnh phúc!",
                "Nhân dịp xuân \(canChi), chúc đồng nghiệp một năm mới tràn đầy năng lượng và thành công!",
                "Năm \(zodiac) chúc mọi người an khang thịnh vượng, tinh thần sảng khoái, công việc hanh thông!"
            ]
        case (.colleagues, .casual):
            return [
                "Happy New Year team! Năm \(canChi) cùng nhau cháy hết mình nha! 🔥",
                "Chúc cả team năm mới \(zodiac) vui vẻ, lương thưởng đầy đủ, OT ít thôi! 😄",
                "Tết \(canChi) rồi! Chúc mọi người năm mới phát tài, code không bug! 🎊"
            ]

        // Teachers
        case (.teachers, .formal):
            return [
                "Em kính chúc Thầy/Cô năm \(canChi) sức khỏe dồi dào, công tác thuận lợi, gia đình hạnh phúc!",
                "Nhân dịp Tết \(canChi), em xin gửi lời chúc tốt đẹp nhất đến Thầy/Cô. Cảm ơn Thầy/Cô đã dìu dắt em!",
                "Năm \(zodiac) em kính chúc Thầy/Cô vạn sự như ý, luôn tràn đầy nhiệt huyết với sự nghiệp trồng người!"
            ]
        case (.teachers, .casual):
            return [
                "Chúc Thầy/Cô năm mới \(canChi) vui vẻ, khỏe mạnh! Em nhớ Thầy/Cô nhiều ạ! 📚",
                "Happy New Year Thầy/Cô! Năm \(zodiac) chúc Thầy/Cô luôn hạnh phúc! 🎉",
                "Tết \(canChi) rồi! Em chúc Thầy/Cô năm mới tràn ngập niềm vui!"
            ]

        // Friends
        case (.friends, .formal):
            return [
                "Chúc bạn năm \(canChi) sức khỏe, thành công, vạn sự như ý!",
                "Năm \(zodiac) chúc bạn mọi điều tốt đẹp, công việc thuận lợi, tình cảm viên mãn!",
                "Nhân dịp Tết \(canChi), chúc bạn một năm mới an khang thịnh vượng!"
            ]
        case (.friends, .casual):
            return [
                "Happy New Year bạn ơi! Năm \(canChi) chúc bạn phát tài phát lộc! 🧧",
                "Tết \(zodiac) rồi! Chúc mày năm mới vui vẻ, có người yêu (nếu chưa có)! 😄",
                "Chúc bạn năm mới \(canChi) khỏe mạnh, thành công, và quan trọng nhất là GIÀU! 💰"
            ]
        case (.friends, .funny):
            return [
                "Năm \(canChi) chúc mày: Tiền vào như nước, tiền ra như... từ từ thôi! 😂",
                "Happy New Year! Chúc năm \(zodiac) mày đẹp trai/xinh gái hơn... tao một chút thôi! 🤣",
                "Tết \(canChi) rồi! Chúc mày năm mới ế ít hơn năm cũ nha! Just kidding! 😜",
                "Năm mới chúc bạn: Cân nặng giảm, lương tăng, crush để ý! 🎊"
            ]

        // Partner
        case (.partner, .formal):
            return [
                "Chúc em/anh năm \(canChi) sức khỏe, hạnh phúc. Cảm ơn em/anh đã luôn bên cạnh!",
                "Năm \(zodiac) anh/em chúc em/anh mọi điều tốt đẹp nhất. Mong chúng mình mãi bên nhau!",
                "Nhân dịp Tết \(canChi), anh/em muốn nói: Cảm ơn em/anh vì tất cả!"
            ]
        case (.partner, .casual):
            return [
                "Happy New Year bé yêu! Năm \(canChi) mình cùng nhau hạnh phúc nha! 💕",
                "Tết \(zodiac) rồi! Chúc người yêu của anh/em luôn xinh đẹp/đẹp trai, khỏe mạnh! ❤️",
                "Năm mới \(canChi) chúc bé: Được yêu nhiều hơn, được chiều nhiều hơn! 🥰"
            ]
        case (.partner, .romantic):
            return [
                "Năm \(canChi), anh/em chỉ có một điều ước: Được bên em/anh mãi mãi. Yêu em/anh! 💕",
                "Tết này có em/anh, đời anh/em trọn vẹn. Chúc chúng mình năm \(zodiac) thật hạnh phúc! ❤️",
                "Em/Anh là món quà tuyệt vời nhất của năm cũ. Năm \(canChi) mình tiếp tục viết câu chuyện tình yêu nhé! 💑",
                "365 ngày qua có em/anh, 365 ngày tới anh/em vẫn muốn có em/anh. Happy New Year, người anh/em yêu! 💖"
            ]

        // Children
        case (.children, .formal):
            return [
                "Chúc con năm \(canChi) học giỏi, ngoan ngoãn, vâng lời ông bà cha mẹ!",
                "Năm \(zodiac) ba/mẹ chúc con sức khỏe, học tập tiến bộ, ngày càng trưởng thành!",
                "Nhân dịp Tết \(canChi), ba/mẹ chúc con một năm mới tràn đầy niềm vui và thành công!"
            ]
        case (.children, .casual):
            return [
                "Happy New Year con yêu! Năm \(canChi) chúc con khỏe mạnh, học giỏi, chơi vui! 🎊",
                "Tết \(zodiac) rồi! Chúc con nhiều lì xì, nhiều bánh kẹo nha! 🧧",
                "Năm mới \(canChi) ba/mẹ chúc con: Cao hơn, khỏe hơn, và vẫn đáng yêu như vậy! 💕"
            ]

        default:
            return [
                "Chúc mừng năm mới \(canChi)! Chúc bạn sức khỏe, hạnh phúc, vạn sự như ý!",
                "Năm \(zodiac) chúc bạn an khang thịnh vượng, mọi điều tốt đẹp!",
                "Happy New Year! Tết \(canChi) chúc bạn phát tài phát lộc! 🧧"
            ]
        }
    }

    private static func formatTemplate(_ template: String, with request: GreetingRequest) -> String {
        var result = template
        if let name = request.recipientName, !name.isEmpty {
            // Add personalization if name is provided
            result = result.replacingOccurrences(of: "Ông Bà", with: name)
            result = result.replacingOccurrences(of: "Bố Mẹ", with: name)
            result = result.replacingOccurrences(of: "Sếp", with: name)
            result = result.replacingOccurrences(of: "Thầy/Cô", with: name)
            result = result.replacingOccurrences(of: "bạn ơi", with: "\(name) ơi")
            result = result.replacingOccurrences(of: "bé yêu", with: name)
            result = result.replacingOccurrences(of: "con yêu", with: name)
        }
        return result
    }
}
