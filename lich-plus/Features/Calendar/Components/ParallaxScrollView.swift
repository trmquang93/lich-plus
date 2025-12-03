import SwiftUI

struct ParallaxScrollView<Header: View, Content: View>: View {
    let minHeaderHeight: CGFloat
    let maxHeaderHeight: CGFloat
    @ViewBuilder let header: (CGFloat, CGFloat) -> Header
    @ViewBuilder let content: () -> Content

    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        ZStack(alignment: .top) {
            scrollContent

            header(calculatedHeaderHeight, collapseProgress)
                .frame(height: calculatedHeaderHeight, alignment: .top)
                .clipped()
        }
    }

    @ViewBuilder
    private var scrollContent: some View {
        if #available(iOS 18.0, *) {
            ScrollView {
                VStack(spacing: 0) {
                    Color.clear.frame(height: maxHeaderHeight)
                    content()
                }
            }
            .onScrollGeometryChange(for: CGFloat.self, of: { geo in
                geo.contentOffset.y + geo.contentInsets.top
            }, action: { newValue, _ in
                scrollOffset = newValue
            })
        } else {
            ScrollView {
                VStack(spacing: 0) {
                    Color.clear.frame(height: maxHeaderHeight)
                    content()
                }
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: -geo.frame(in: .named("parallaxScroll")).minY
                        )
                    }
                )
            }
            .coordinateSpace(name: "parallaxScroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
        }
    }

    private var calculatedHeaderHeight: CGFloat {
        if scrollOffset <= 0 {
            return maxHeaderHeight
        } else {
            let collapsed = maxHeaderHeight - scrollOffset
            return max(minHeaderHeight, collapsed)
        }
    }

    private var collapseProgress: CGFloat {
        let range = maxHeaderHeight - minHeaderHeight
        guard range > 0 else { return 0 }
        return (maxHeaderHeight - calculatedHeaderHeight) / range
    }
}

#Preview {
    ParallaxScrollView(
        minHeaderHeight: 100,
        maxHeaderHeight: 300,
        header: { height, progress in
            VStack {
                Text("Parallax Header")
                    .font(.title)
                    .opacity(1.0 - progress)
                Spacer()
                Text("Progress: \(String(format: "%.0f", progress * 100))%")
                    .font(.caption)
                    .opacity(progress)
            }
            .frame(height: height)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.7), .blue.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        },
        content: {
            VStack(spacing: 16) {
                ForEach(0..<20, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Item \(index + 1)")
                            .font(.headline)
                        Text("This is a content item that demonstrates the parallax scroll view in action.")
                            .font(.body)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding()
        }
    )
}
