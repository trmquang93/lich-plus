import Foundation

// MARK: - Can Chi (Heavenly Stems & Earthly Branches) Information
struct CanChiInfo: Codable, Hashable {
    var can: String
    var chi: String

    // MARK: - Display Properties
    var displayName: String {
        "\(can) \(chi)"
    }

    // MARK: - Initializer
    init(can: String, chi: String) {
        self.can = can
        self.chi = chi
    }

    // MARK: - Hashable Implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(can)
        hasher.combine(chi)
    }

    // MARK: - Equatable Implementation
    static func == (lhs: CanChiInfo, rhs: CanChiInfo) -> Bool {
        lhs.can == rhs.can && lhs.chi == rhs.chi
    }
}
