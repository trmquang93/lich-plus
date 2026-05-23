//
//  VanKhanRenderedBody.swift
//  lich-plus
//
//  Renders a văn khấn body with two styles applied:
//  - resolved tokens get a soft gold under-highlight
//  - unresolved `{token}` placeholders render in brand-red tint
//
//  Implementation strategy: render twice — once with substitution, then
//  detect spans by walking the original body and tracking offsets.
//

import SwiftUI

struct VanKhanRenderedBody: View {
    let text: VanKhanText
    let profile: PersonalProfile?
    let overrides: [String: String]
    let context: VanKhanRenderer.Context
    var hiddenSections: Set<VanKhanSectionTag> = []
    var onTapPlaceholder: ((_ key: String, _ currentValue: String) -> Void)? = nil

    private static let editScheme = "vankhanedit"

    var body: some View {
        Text(attributedBody)
            .font(.system(size: 17, weight: .regular, design: .serif))
            .foregroundStyle(AppColors.textPrimary)
            .lineSpacing(4)
            .textSelection(.enabled)
            .tint(AppColors.primary)
            .environment(\.openURL, OpenURLAction { [tokenMap = currentTokenMap] url in
                guard url.scheme == Self.editScheme else { return .systemAction }
                let key = url.host ?? url.lastPathComponent
                onTapPlaceholder?(key, tokenMap[key] ?? "")
                return .handled
            })
    }

    private var attributedBody: AttributedString {
        var attr = AttributedString()

        // Walk the (section-preprocessed) body, emitting plain runs and styled token runs
        let body = VanKhanRenderer.applySections(body: text.body, hidden: hiddenSections)
        let pattern = #"\{([a-zA-Z][a-zA-Z0-9_]*)\}"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            var fallback = AttributedString(body)
            fallback.foregroundColor = AppColors.textPrimary
            return fallback
        }

        let ns = body as NSString
        let matches = regex.matches(in: body, range: NSRange(location: 0, length: ns.length))
        var cursor = 0

        let tokenMap = currentTokenMap

        for match in matches {
            // Plain run before this token
            if match.range.location > cursor {
                let plain = ns.substring(with: NSRange(location: cursor, length: match.range.location - cursor))
                attr.append(AttributedString(plain))
            }

            let key = ns.substring(with: match.range(at: 1))
            if let value = tokenMap[key], !value.isEmpty {
                var resolved = AttributedString(value)
                if let url = URL(string: "\(Self.editScheme)://\(key)") {
                    resolved.link = url
                }
                resolved.backgroundColor = AppColors.hoangDaoGold.opacity(0.25)
                resolved.foregroundColor = AppColors.textPrimary
                resolved.underlineStyle = nil
                attr.append(resolved)
            } else {
                var missing = AttributedString("{\(VanKhanToken.displayLabel(forKey: key))}")
                if let url = URL(string: "\(Self.editScheme)://\(key)") {
                    missing.link = url
                }
                missing.foregroundColor = AppColors.primary
                missing.backgroundColor = AppColors.backgroundLight
                missing.underlineStyle = nil
                attr.append(missing)
            }

            cursor = match.range.location + match.range.length
        }

        if cursor < ns.length {
            attr.append(AttributedString(ns.substring(from: cursor)))
        }

        return attr
    }

    private var currentTokenMap: [String: String] {
        // Mirror VanKhanRenderer's token assembly so we know what is resolved.
        var tokens: [String: String] = [:]
        if let p = profile {
            tokens[VanKhanToken.name.rawValue] = p.fullName
            tokens[VanKhanToken.address.rawValue] = p.address
            tokens[VanKhanToken.familyName.rawValue] = p.familyName
            if let g = p.gender { tokens[VanKhanToken.gender.rawValue] = g }
            if let s = p.spouseName { tokens[VanKhanToken.spouseName.rawValue] = s }
        }
        if let r = context.deceasedRelative {
            tokens[VanKhanToken.deceasedName.rawValue] = r.name
            tokens[VanKhanToken.deceasedRelation.rawValue] = r.relation
        }
        if let c = context.childName, !c.isEmpty {
            tokens[VanKhanToken.childName.rawValue] = c
        }
        let solarFmt = DateFormatter()
        solarFmt.dateFormat = "dd/MM/yyyy"
        tokens[VanKhanToken.solarDate.rawValue] = solarFmt.string(from: context.date)
        let lunar = LunarCalendar.solarToLunar(context.date)
        tokens[VanKhanToken.lunarDate.rawValue] = String(format: "%02d/%02d/%04d", lunar.day, lunar.month, lunar.year)
        for (k, v) in overrides where !v.isEmpty { tokens[k] = v }
        return tokens.filter { !$0.value.isEmpty }
    }
}
