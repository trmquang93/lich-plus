//
//  VanKhanRenderer.swift
//  lich-plus
//
//  Token substitution for văn khấn bodies. Pure logic — unit-testable.
//

import Foundation

enum VanKhanRenderer {

    /// Inputs that influence token substitution beyond the static profile.
    struct Context {
        var date: Date
        var deceasedRelative: DeceasedRelative?
        var childName: String?

        init(date: Date = Date(), deceasedRelative: DeceasedRelative? = nil, childName: String? = nil) {
            self.date = date
            self.deceasedRelative = deceasedRelative
            self.childName = childName
        }
    }

    /// Render `text` with personal + override tokens substituted.
    ///
    /// Unknown tokens are left intact (e.g. `{foo}`) so the UI can highlight
    /// what the user still needs to fill in.
    static func render(
        text: VanKhanText,
        profile: PersonalProfile?,
        overrides: [String: String] = [:],
        context: Context = Context()
    ) -> String {
        let tokens = buildTokenMap(profile: profile, overrides: overrides, context: context)

        // Find {key} placeholders; only substitute keys present in the map
        // (and non-empty values). Leaves unknown / empty tokens intact.
        var result = text.body
        let pattern = #"\{([a-zA-Z][a-zA-Z0-9_]*)\}"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return result
        }

        // Walk matches in reverse so range offsets remain valid as we mutate.
        let ns = result as NSString
        let matches = regex.matches(in: result, range: NSRange(location: 0, length: ns.length))
        for match in matches.reversed() {
            guard match.numberOfRanges >= 2 else { continue }
            let key = ns.substring(with: match.range(at: 1))
            if let value = tokens[key], !value.isEmpty {
                result = (result as NSString).replacingCharacters(in: match.range, with: value)
            }
        }
        return result
    }

    /// The unresolved tokens in a rendered string — useful for the UI to
    /// highlight what the user still needs to fill in.
    static func unresolvedTokens(in rendered: String) -> [String] {
        let pattern = #"\{([a-zA-Z][a-zA-Z0-9_]*)\}"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let ns = rendered as NSString
        return regex.matches(in: rendered, range: NSRange(location: 0, length: ns.length))
            .compactMap { $0.numberOfRanges >= 2 ? ns.substring(with: $0.range(at: 1)) : nil }
    }

    // MARK: - Token map

    private static func buildTokenMap(
        profile: PersonalProfile?,
        overrides: [String: String],
        context: Context
    ) -> [String: String] {
        var tokens: [String: String] = [:]

        // Personal profile
        if let p = profile {
            tokens["name"] = p.fullName
            tokens["address"] = p.address
            if let g = p.gender { tokens["gender"] = g }
            if let spouse = p.spouseName { tokens["spouseName"] = spouse }
        }

        // Deceased (giỗ)
        if let r = context.deceasedRelative {
            tokens["deceasedName"] = r.name
            tokens["deceasedRelation"] = r.relation
        }

        // Child (đầy tháng / thôi nôi)
        if let c = context.childName, !c.isEmpty {
            tokens["childName"] = c
        }

        // Dates
        let solarFormatter = DateFormatter()
        solarFormatter.dateFormat = "dd/MM/yyyy"
        tokens["solarDate"] = solarFormatter.string(from: context.date)

        let lunar = LunarCalendar.solarToLunar(context.date)
        tokens["lunarDate"] = String(format: "%02d/%02d/%04d", lunar.day, lunar.month, lunar.year)

        // Overrides win.
        for (k, v) in overrides where !v.isEmpty {
            tokens[k] = v
        }

        // Drop empty values so the regex pass leaves the placeholder in place.
        return tokens.filter { !$0.value.isEmpty }
    }
}
