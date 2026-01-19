//
//  FlowLayout.swift
//  lich-plus
//

import SwiftUI

/// A layout that arranges its subviews in a flowing manner, wrapping to the next line when needed.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var alignment: HorizontalAlignment = .leading

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            maxWidth: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing,
            alignment: alignment
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            maxWidth: bounds.width,
            subviews: subviews,
            spacing: spacing,
            alignment: alignment
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat, alignment: HorizontalAlignment) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            var sizes: [CGSize] = []

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                sizes.append(size)
            }

            for (index, size) in sizes.enumerated() {
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }

            currentY += lineHeight

            switch alignment {
            case .leading:
                break
            case .center:
                var rowStart = 0
                var rowWidth: CGFloat = 0
                var currentRowX: CGFloat = 0
                var index = 0

                while index < positions.count {
                    rowStart = index
                    rowWidth = 0
                    currentRowX = 0

                    while index < positions.count && (index == rowStart || currentRowX + sizes[index].width <= maxWidth) {
                        rowWidth = currentRowX + sizes[index].width
                        currentRowX += sizes[index].width + spacing
                        index += 1
                    }

                    let offset = (maxWidth - rowWidth) / 2
                    for i in rowStart..<min(index, positions.count) {
                        positions[i].x += offset
                    }
                }
            case .trailing:
                var rowStart = 0
                var rowWidth: CGFloat = 0
                var currentRowX: CGFloat = 0
                var index = 0

                while index < positions.count {
                    rowStart = index
                    rowWidth = 0
                    currentRowX = 0

                    while index < positions.count && (index == rowStart || currentRowX + sizes[index].width <= maxWidth) {
                        rowWidth = currentRowX + sizes[index].width
                        currentRowX += sizes[index].width + spacing
                        index += 1
                    }

                    let offset = maxWidth - rowWidth
                    for i in rowStart..<min(index, positions.count) {
                        positions[i].x += offset
                    }
                }
            default:
                break
            }

            self.size = CGSize(width: maxWidth, height: currentY)
        }
    }
}
