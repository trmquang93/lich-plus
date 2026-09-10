//
//  ElderModeStore.swift
//  lich-plus
//
//  Large-text / simplified UI preference for parents and elders.
//

import SwiftUI
import Combine

@MainActor
final class ElderModeStore: ObservableObject {
    static let shared = ElderModeStore()

    private static let storageKey = "elder_mode_enabled_v1"

    @Published private(set) var isEnabled: Bool

    /// Scales fixed AppTheme font tokens when elder mode is on.
    var fontScale: CGFloat { isEnabled ? 1.22 : 1.0 }

    /// Extra spacing for calmer, one-hand friendly layouts.
    var spacingScale: CGFloat { isEnabled ? 1.15 : 1.0 }

    private init() {
        isEnabled = UserDefaults.standard.bool(forKey: Self.storageKey)
    }

    func setEnabled(_ enabled: Bool) {
        guard enabled != isEnabled else { return }
        isEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: Self.storageKey)
        if enabled {
            AnalyticsService.shared.logFeatureUsed(.elder_mode)
        }
    }
}

private struct ElderModeKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var elderModeEnabled: Bool {
        get { self[ElderModeKey.self] }
        set { self[ElderModeKey.self] = newValue }
    }
}

struct ElderModeFontModifier: ViewModifier {
    @Environment(\.elderModeEnabled) private var elderModeEnabled
    let baseSize: CGFloat
    let weight: Font.Weight
    let design: Font.Design

    func body(content: Content) -> some View {
        content.font(.system(
            size: baseSize * (elderModeEnabled ? 1.22 : 1.0),
            weight: weight,
            design: design
        ))
    }
}

extension View {
    func elderModeFont(
        size: CGFloat,
        weight: Font.Weight = .regular,
        design: Font.Design = .default
    ) -> some View {
        modifier(ElderModeFontModifier(baseSize: size, weight: weight, design: design))
    }

    func elderModePadding(_ edges: Edge.Set = .all, _ length: CGFloat) -> some View {
        modifier(ElderModePaddingModifier(edges: edges, length: length))
    }
}

private struct ElderModePaddingModifier: ViewModifier {
    @Environment(\.elderModeEnabled) private var elderModeEnabled
    let edges: Edge.Set
    let length: CGFloat

    func body(content: Content) -> some View {
        content.padding(edges, length * (elderModeEnabled ? 1.15 : 1.0))
    }
}
