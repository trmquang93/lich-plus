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

    var body: some View {
        Text(attributedBody)
            .font(.system(size: 17, weight: .regular, design: .serif))
            .foregroundStyle(AppColors.textPrimary)
            .lineSpacing(4)
            .textSelection(.enabled)
    }

    private var attributedBody: AttributedString {
        var attr = AttributedString()

        // Walk the original body, emitting plain runs and styled token runs
        let body = text.body
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
                resolved.backgroundColor = AppColors.hoangDaoGold.opacity(0.25)
                resolved.foregroundColor = AppColors.textPrimary
                attr.append(resolved)
            } else {
                var missing = AttributedString("{\(key)}")
                missing.foregroundColor = AppColors.primary
                missing.backgroundColor = AppColors.backgroundLight
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
            tokens["name"] = p.fullName
            tokens["address"] = p.address
            if let g = p.gender { tokens["gender"] = g }
            if let s = p.spouseName { tokens["spouseName"] = s }
        }
        if let r = context.deceasedRelative {
            tokens["deceasedName"] = r.name
            tokens["deceasedRelation"] = r.relation
        }
        if let c = context.childName, !c.isEmpty {
            tokens["childName"] = c
        }
        let solarFmt = DateFormatter()
        solarFmt.dateFormat = "dd/MM/yyyy"
        tokens["solarDate"] = solarFmt.string(from: context.date)
        let lunar = LunarCalendar.solarToLunar(context.date)
        tokens["lunarDate"] = String(format: "%02d/%02d/%04d", lunar.day, lunar.month, lunar.year)
        for (k, v) in overrides where !v.isEmpty { tokens[k] = v }
        return tokens.filter { !$0.value.isEmpty }
    }
}
