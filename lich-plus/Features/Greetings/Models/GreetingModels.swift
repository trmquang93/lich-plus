//
//  GreetingModels.swift
//  lich-plus
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

    /// Display name
    var displayName: String {
        switch self {
        case .grandparents: return String(localized: "Grandparents")
        case .parents: return String(localized: "Parents")
        case .boss: return String(localized: "Boss")
        case .colleagues: return String(localized: "Colleagues")
        case .teachers: return String(localized: "Teachers")
        case .friends: return String(localized: "Friends")
        case .partner: return String(localized: "Partner")
        case .children: return String(localized: "Children")
        }
    }

    /// Default recipient name to use when no custom name is provided
    func defaultRecipientName(for language: GreetingLanguage) -> String {
        switch language {
        case .vietnamese:
            switch self {
            case .grandparents: return "Ông Bà"
            case .parents: return "Bố Mẹ"
            case .boss: return "Anh/Chị"
            case .colleagues: return "Anh/Chị"
            case .teachers: return "Thầy/Cô"
            case .friends: return "bạn"
            case .partner: return "em/anh"
            case .children: return "con"
            }
        case .english:
            switch self {
            case .grandparents: return "Grandparents"
            case .parents: return "Mom and Dad"
            case .boss: return "Boss"
            case .colleagues: return "Colleague"
            case .teachers: return "Teacher"
            case .friends: return "friend"
            case .partner: return "my love"
            case .children: return "sweetheart"
            }
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

    /// Display name
    var displayName: String {
        switch self {
        case .formal: return String(localized: "Formal")
        case .casual: return String(localized: "Casual")
        case .funny: return String(localized: "Playful")
        case .romantic: return String(localized: "Romantic")
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

    /// Get zodiac animal for a given lunar year
    static func zodiacAnimal(for year: Int) -> String {
        let chi = CanChiCalculator.calculateYearCanChi(lunarYear: year).chi
        let emoji: String
        switch chi {
        case .ty: emoji = "🐀"
        case .suu: emoji = "🐂"
        case .dan: emoji = "🐅"
        case .mao: emoji = "🐇"
        case .thin: emoji = "🐉"
        case .ty2: emoji = "🐍"
        case .ngo: emoji = "🐴"
        case .mui: emoji = "🐐"
        case .than: emoji = "🐒"
        case .dau: emoji = "🐓"
        case .tuat: emoji = "🐕"
        case .hoi: emoji = "🐖"
        }
        return "\(emoji) \(chi.vietnameseName)"
    }

    /// Get Can-Chi for a given lunar year
    static func canChi(for year: Int) -> String {
        return CanChiCalculator.calculateYearCanChi(lunarYear: year).displayName
    }
}

// MARK: - Greeting Language

/// Language for greeting messages
enum GreetingLanguage: String, CaseIterable, Identifiable {
    case vietnamese = "vi"
    case english = "en"

    var id: String { rawValue }

    /// Display name
    var displayName: String {
        switch self {
        case .vietnamese: return "Tiếng Việt"
        case .english: return "English"
        }
    }

    /// Flag emoji
    var flag: String {
        switch self {
        case .vietnamese: return "🇻🇳"
        case .english: return "🇺🇸"
        }
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
    let language: GreetingLanguage

    init(
        recipientType: RecipientType,
        tone: GreetingTone,
        occasion: GreetingOccasion = .tet,
        recipientName: String? = nil,
        additionalInfo: String? = nil,
        year: Int = Calendar.current.component(.year, from: Date()),
        language: GreetingLanguage = .vietnamese
    ) {
        self.recipientType = recipientType
        self.tone = tone
        self.occasion = occasion
        self.recipientName = recipientName
        self.additionalInfo = additionalInfo
        self.year = year
        self.language = language
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
        if request.language == .english {
            return getEnglishTemplates(for: request)
        }

        return getVietnameseTemplates(for: request)
    }

    private static func getVietnameseTemplates(for request: GreetingRequest) -> [String] {
        let canChi = GreetingOccasion.canChi(for: request.year)
        let zodiac = GreetingOccasion.zodiacAnimal(for: request.year)

        switch (request.recipientType, request.tone) {
        // Grandparents
        case (.grandparents, .formal):
            return [
                "Cháu kính chúc {{recipient}} năm \(canChi) sức khỏe dồi dào, trường thọ bách niên, vạn sự như ý. Mong {{recipient}} luôn vui khỏe để con cháu được sum vầy mỗi dịp Tết!",
                "Nhân dịp Tết \(canChi), cháu kính chúc {{recipient}} an khang thịnh vượng, phúc lộc đầy nhà, sống lâu trăm tuổi!",
                "Kính chúc {{recipient}} năm mới \(zodiac) mạnh khỏe, bình an, gia đình hạnh phúc, con cháu thảo hiền!"
            ]
        case (.grandparents, .casual):
            return [
                "Chúc {{recipient}} năm mới khỏe mạnh, vui vẻ! Cháu thương {{recipient}} nhiều lắm ạ! 🧧",
                "{{recipient}} ơi, Tết \(canChi) rồi! Chúc {{recipient}} luôn khỏe để cháu được về thăm hoài nha!",
                "Happy New Year {{recipient}}! Năm \(zodiac) chúc {{recipient}} khỏe re, vui vẻ! 🎊"
            ]

        // Parents
        case (.parents, .formal):
            return [
                "Con kính chúc {{recipient}} năm \(canChi) sức khỏe dồi dào, vạn sự như ý. Cảm ơn {{recipient}} đã luôn yêu thương và chở che cho con!",
                "Nhân dịp xuân \(canChi), con kính chúc {{recipient}} an khang thịnh vượng, gia đình hạnh phúc, công việc thuận lợi!",
                "Năm \(zodiac), con chúc {{recipient}} sức khỏe bình an, mọi điều tốt đẹp, luôn vui vẻ bên con cháu!"
            ]
        case (.parents, .casual):
            return [
                "{{recipient}} ơi, Happy New Year! Chúc {{recipient}} năm mới khỏe mạnh, vui vẻ! Con yêu {{recipient}}! ❤️",
                "Tết \(canChi) rồi! Chúc {{recipient}} năm mới phát tài phát lộc, khỏe mạnh, hạnh phúc nha!",
                "Năm \(zodiac) chúc {{recipient}} luôn trẻ khỏe, vui tươi! Con sẽ cố gắng để {{recipient}} tự hào! 🧧"
            ]

        // Boss
        case (.boss, .formal):
            return [
                "Kính chúc {{recipient}} năm \(canChi) sức khỏe dồi dào, công việc thuận lợi, vạn sự hanh thông!",
                "Nhân dịp Tết \(canChi), kính chúc {{recipient}} một năm mới thành công rực rỡ, mọi dự án đều thuận buồm xuôi gió!",
                "Chúc {{recipient}} năm \(zodiac) đại cát đại lợi, sự nghiệp thăng tiến, gia đình hạnh phúc!"
            ]
        case (.boss, .casual):
            return [
                "Chúc {{recipient}} năm mới \(canChi) vui vẻ, công việc suôn sẻ! Cảm ơn {{recipient}} đã hỗ trợ em trong năm qua! 🎉",
                "Happy New Year {{recipient}}! Năm \(zodiac) chúc {{recipient}} khỏe mạnh, thành công! 🧧",
                "Tết \(canChi) rồi {{recipient}} ơi! Chúc {{recipient}} năm mới phát tài, công ty phát triển!"
            ]

        // Colleagues
        case (.colleagues, .formal):
            return [
                "Chúc {{recipient}} năm \(canChi) sức khỏe, công việc thuận lợi, gia đình hạnh phúc!",
                "Nhân dịp xuân \(canChi), chúc {{recipient}} một năm mới tràn đầy năng lượng và thành công!",
                "Năm \(zodiac) chúc {{recipient}} an khang thịnh vượng, tinh thần sảng khoái, công việc hanh thông!"
            ]
        case (.colleagues, .casual):
            return [
                "Happy New Year team! Năm \(canChi) cùng nhau cháy hết mình nha! 🔥",
                "Chúc cả team năm mới \(zodiac) vui vẻ, lương thưởng đầy đủ, OT ít thôi! 😄",
                "Tết \(canChi) rồi! Chúc {{recipient}} năm mới phát tài, code không bug! 🎊"
            ]

        // Teachers
        case (.teachers, .formal):
            return [
                "Em kính chúc {{recipient}} năm \(canChi) sức khỏe dồi dào, công tác thuận lợi, gia đình hạnh phúc!",
                "Nhân dịp Tết \(canChi), em xin gửi lời chúc tốt đẹp nhất đến {{recipient}}. Cảm ơn {{recipient}} đã dìu dắt em!",
                "Năm \(zodiac) em kính chúc {{recipient}} vạn sự như ý, luôn tràn đầy nhiệt huyết với sự nghiệp trồng người!"
            ]
        case (.teachers, .casual):
            return [
                "Chúc {{recipient}} năm mới \(canChi) vui vẻ, khỏe mạnh! Em nhớ {{recipient}} nhiều ạ! 📚",
                "Happy New Year {{recipient}}! Năm \(zodiac) chúc {{recipient}} luôn hạnh phúc! 🎉",
                "Tết \(canChi) rồi! Em chúc {{recipient}} năm mới tràn ngập niềm vui!"
            ]

        // Friends
        case (.friends, .formal):
            return [
                "Chúc {{recipient}} năm \(canChi) sức khỏe, thành công, vạn sự như ý!",
                "Năm \(zodiac) chúc {{recipient}} mọi điều tốt đẹp, công việc thuận lợi, tình cảm viên mãn!",
                "Nhân dịp Tết \(canChi), chúc {{recipient}} một năm mới an khang thịnh vượng!"
            ]
        case (.friends, .casual):
            return [
                "Happy New Year {{recipient}} ơi! Năm \(canChi) chúc {{recipient}} phát tài phát lộc! 🧧",
                "Tết \(zodiac) rồi! Chúc {{recipient}} năm mới vui vẻ, có người yêu (nếu chưa có)! 😄",
                "Chúc {{recipient}} năm mới \(canChi) khỏe mạnh, thành công, và quan trọng nhất là GIÀU! 💰"
            ]
        case (.friends, .funny):
            return [
                "Năm \(canChi) chúc {{recipient}}: Tiền vào như nước, tiền ra như... từ từ thôi! 😂",
                "Happy New Year! Chúc năm \(zodiac) {{recipient}} đẹp trai/xinh gái hơn... tao một chút thôi! 🤣",
                "Tết \(canChi) rồi! Chúc {{recipient}} năm mới ế ít hơn năm cũ nha! Just kidding! 😜",
                "Năm mới chúc {{recipient}}: Cân nặng giảm, lương tăng, crush để ý! 🎊"
            ]

        // Partner
        case (.partner, .formal):
            return [
                "Chúc {{recipient}} năm \(canChi) sức khỏe, hạnh phúc. Cảm ơn {{recipient}} đã luôn bên cạnh!",
                "Năm \(zodiac) chúc {{recipient}} mọi điều tốt đẹp nhất. Mong chúng mình mãi bên nhau!",
                "Nhân dịp Tết \(canChi), muốn nói: Cảm ơn {{recipient}} vì tất cả!"
            ]
        case (.partner, .casual):
            return [
                "Happy New Year bé yêu! Năm \(canChi) mình cùng nhau hạnh phúc nha! 💕",
                "Tết \(zodiac) rồi! Chúc người yêu của anh/em luôn xinh đẹp/đẹp trai, khỏe mạnh! ❤️",
                "Năm mới \(canChi) chúc bé: Được yêu nhiều hơn, được chiều nhiều hơn! 🥰"
            ]
        case (.partner, .romantic):
            return [
                "Năm \(canChi), chỉ có một điều ước: Được bên {{recipient}} mãi mãi. Yêu {{recipient}}! 💕",
                "Tết này có {{recipient}}, đời trọn vẹn. Chúc chúng mình năm \(zodiac) thật hạnh phúc! ❤️",
                "{{recipient}} là món quà tuyệt vời nhất của năm cũ. Năm \(canChi) mình tiếp tục viết câu chuyện tình yêu nhé! 💑",
                "365 ngày qua có {{recipient}}, 365 ngày tới vẫn muốn có {{recipient}}. Happy New Year, người yêu! 💖"
            ]

        // Children
        case (.children, .formal):
            return [
                "Chúc {{recipient}} năm \(canChi) học giỏi, ngoan ngoãn, vâng lời ông bà cha mẹ!",
                "Năm \(zodiac) chúc {{recipient}} sức khỏe, học tập tiến bộ, ngày càng trưởng thành!",
                "Nhân dịp Tết \(canChi), chúc {{recipient}} một năm mới tràn đầy niềm vui và thành công!"
            ]
        case (.children, .casual):
            return [
                "Happy New Year {{recipient}}! Năm \(canChi) chúc {{recipient}} khỏe mạnh, học giỏi, chơi vui! 🎊",
                "Tết \(zodiac) rồi! Chúc {{recipient}} nhiều lì xì, nhiều bánh kẹo nha! 🧧",
                "Năm mới \(canChi) chúc {{recipient}}: Cao hơn, khỏe hơn, và vẫn đáng yêu như vậy! 💕"
            ]

        default:
            return [
                "Chúc mừng năm mới \(canChi)! Chúc {{recipient}} sức khỏe, hạnh phúc, vạn sự như ý!",
                "Năm \(zodiac) chúc {{recipient}} an khang thịnh vượng, mọi điều tốt đẹp!",
                "Happy New Year! Tết \(canChi) chúc {{recipient}} phát tài phát lộc! 🧧"
            ]
        }
    }

    private static func getEnglishTemplates(for request: GreetingRequest) -> [String] {
        let canChi = GreetingOccasion.canChi(for: request.year)
        let zodiac = GreetingOccasion.zodiacAnimal(for: request.year)

        switch (request.recipientType, request.tone) {
        // Grandparents
        case (.grandparents, .formal):
            return [
                "Wishing {{recipient}} good health, longevity, and prosperity in the year \(canChi). May you always be joyful to see your family gather every Tet!",
                "On the occasion of Tet \(canChi), respectfully wishing {{recipient}} peace, prosperity, and abundance in your home. May you live to a hundred years!",
                "Wishing {{recipient}} health and peace in the new year \(zodiac). May your family be happy and your descendants be filial!"
            ]
        case (.grandparents, .casual):
            return [
                "Happy New Year {{recipient}}! Wishing you health and joy in the year \(canChi)! I love you so much! 🧧",
                "{{recipient}}, Tet \(canChi) is here! Wishing you health so I can keep visiting you!",
                "Happy New Year {{recipient}}! Wishing you health and happiness in the year \(zodiac)! 🎊"
            ]

        // Parents
        case (.parents, .formal):
            return [
                "Respectfully wishing {{recipient}} abundant health and all your wishes come true in the year \(canChi). Thank you for always loving and protecting me!",
                "On the occasion of spring \(canChi), respectfully wishing {{recipient}} peace, prosperity, family happiness, and success in work!",
                "In the year \(zodiac), I wish {{recipient}} health and peace, all things good, and always joyful with your family!"
            ]
        case (.parents, .casual):
            return [
                "Happy New Year {{recipient}}! Wishing you health and joy in the new year! Love you! ❤️",
                "Tet \(canChi) is here! Wishing {{recipient}} prosperity, health, and happiness this year!",
                "Year \(zodiac) wishing {{recipient}} always young and healthy! I will try to make you proud! 🧧"
            ]

        // Boss
        case (.boss, .formal):
            return [
                "Respectfully wishing {{recipient}} abundant health, smooth work, and success in everything in the year \(canChi)!",
                "On the occasion of Tet \(canChi), respectfully wishing {{recipient}} a brilliantly successful new year, with every project going smoothly!",
                "Wishing {{recipient}} great fortune and success in the year \(zodiac), career advancement, and family happiness!"
            ]
        case (.boss, .casual):
            return [
                "Happy New Year {{recipient}}! Wishing you joy and smooth work in the year \(canChi)! Thank you for supporting me this past year! 🎉",
                "Happy New Year {{recipient}}! Year \(zodiac) wishing you health and success! 🧧",
                "Tet \(canChi) is here {{recipient}}! Wishing you prosperity and company growth this year!"
            ]

        // Colleagues
        case (.colleagues, .formal):
            return [
                "Wishing {{recipient}} health, work success, and family happiness in the year \(canChi)!",
                "On the occasion of spring \(canChi), wishing {{recipient}} a new year full of energy and success!",
                "Year \(zodiac) wishing {{recipient}} peace and prosperity, refreshed spirit, and successful work!"
            ]
        case (.colleagues, .casual):
            return [
                "Happy New Year team! Let's burn it together this year \(canChi)! 🔥",
                "Wishing the team joy in year \(zodiac), good salary and bonuses, and less OT! 😄",
                "Tet \(canChi) is here! Wishing {{recipient}} prosperity and bug-free code this year! 🎊"
            ]

        // Teachers
        case (.teachers, .formal):
            return [
                "Respectfully wishing {{recipient}} abundant health, smooth work, and family happiness in the year \(canChi)!",
                "On the occasion of Tet \(canChi), respectfully sending my best wishes to {{recipient}}. Thank you for guiding me!",
                "In the year \(zodiac), respectfully wishing {{recipient}} everything goes well, and always full of enthusiasm for your teaching career!"
            ]
        case (.teachers, .casual):
            return [
                "Happy New Year {{recipient}}! Wishing you joy and health in year \(canChi)! I miss you! 📚",
                "Happy New Year {{recipient}}! Year \(zodiac) wishing you always happy! 🎉",
                "Tet \(canChi) is here! Wishing {{recipient}} a new year full of joy!"
            ]

        // Friends
        case (.friends, .formal):
            return [
                "Wishing {{recipient}} health, success, and prosperity in the year \(canChi)!",
                "Year \(zodiac) wishing {{recipient}} all things good, smooth work, and fulfilling relationships!",
                "On the occasion of Tet \(canChi), wishing {{recipient}} a new year of peace and prosperity!"
            ]
        case (.friends, .casual):
            return [
                "Happy New Year {{recipient}}! Wishing you prosperity in the year \(canChi)! 🧧",
                "Tet \(zodiac) is here! Wishing {{recipient}} joy this year, and may you find love (if you don't have one yet)! 😄",
                "Wishing {{recipient}} health, success, and most importantly, RICH in the new year \(canChi)! 💰"
            ]
        case (.friends, .funny):
            return [
                "Year \(canChi) wishing {{recipient}}: Money flows in like water, money goes out like... slowly! 😂",
                "Happy New Year! Wishing year \(zodiac) you're more handsome/beautiful than me... just a little bit! 🤣",
                "Tet \(canChi) is here! Wishing {{recipient}} fewer lonely days this year than last! Just kidding! 😜",
                "New year wishing {{recipient}}: Weight down, salary up, crush notices you! 🎊"
            ]

        // Partner
        case (.partner, .formal):
            return [
                "Wishing {{recipient}} health and happiness in the year \(canChi). Thank you for always being by my side!",
                "Year \(zodiac) wishing {{recipient}} all the best things. Hope we stay together forever!",
                "On the occasion of Tet \(canChi), I want to say: Thank you for everything!"
            ]
        case (.partner, .casual):
            return [
                "Happy New Year my love! Let's be happy together in year \(canChi)! 💕",
                "Tet \(zodiac) is here! Wishing my love always beautiful/handsome and healthy! ❤️",
                "New year \(canChi) wishing you: Be loved more, be pampered more! 🥰"
            ]
        case (.partner, .romantic):
            return [
                "Year \(canChi), only one wish: To be with {{recipient}} forever. Love you! 💕",
                "This Tet has {{recipient}}, life is complete. Wishing us true happiness in year \(zodiac)! ❤️",
                "{{recipient}} is the best gift of last year. Year \(canChi) let's continue writing our love story! 💑",
                "365 days past had {{recipient}}, 365 days ahead I still want {{recipient}}. Happy New Year, my love! 💖"
            ]

        // Children
        case (.children, .formal):
            return [
                "Wishing {{recipient}} good study, obedience, and respect for grandparents and parents in the year \(canChi)!",
                "Year \(zodiac) wishing {{recipient}} health, study progress, and growing maturity!",
                "On the occasion of Tet \(canChi), wishing {{recipient}} a new year full of joy and success!"
            ]
        case (.children, .casual):
            return [
                "Happy New Year {{recipient}}! Wishing you health, good study, and fun play in year \(canChi)! 🎊",
                "Tet \(zodiac) is here! Wishing {{recipient}} lots of lucky money and candies! 🧧",
                "New year \(canChi) wishing {{recipient}}: Taller, healthier, and still as cute as that! 💕"
            ]

        default:
            return [
                "Happy New Year \(canChi)! Wishing {{recipient}} health, happiness, and prosperity!",
                "Year \(zodiac) wishing {{recipient}} peace and prosperity, all things good!",
                "Happy New Year! Tet \(canChi) wishing {{recipient}} prosperity! 🧧"
            ]
        }
    }

    private static func formatTemplate(_ template: String, with request: GreetingRequest) -> String {
        // Use custom name if provided, otherwise use default recipient name
        let replacement: String
        if let name = request.recipientName, !name.isEmpty {
            replacement = name
        } else {
            replacement = request.recipientType.defaultRecipientName(for: request.language)
        }
        return template.replacingOccurrences(of: "{{recipient}}", with: replacement)
    }
}
