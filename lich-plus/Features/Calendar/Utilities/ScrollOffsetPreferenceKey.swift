import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension View {
    func trackScrollOffset() -> some View {
        self.background(
            GeometryReader { geometry in
                Color.clear.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: geometry.frame(in: .named("scrollView")).minY
                )
            }
        )
    }

    /// Track scroll offset using a callback (works inside UIViewControllerRepresentable)
    func trackScrollOffset(onChange: @escaping (CGFloat) -> Void) -> some View {
        self.background(
            GeometryReader { geometry in
                Color.clear
                    .onChange(of: geometry.frame(in: .named("scrollView")).minY) { _, newValue in
                        onChange(newValue)
                    }
                    .onAppear {
                        onChange(geometry.frame(in: .named("scrollView")).minY)
                    }
            }
        )
    }
}
