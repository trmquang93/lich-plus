//
//  EventBlockBackground.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 13/12/25.
//

import SwiftUI

struct EventBlockBackground: View {
    let categoryColor: Color
    let isPast: Bool
    let isCurrent: Bool

    // MARK: - Private Properties

    @State private var isGlowing = false

    // MARK: - Computed Properties

    private var effectiveColor: Color {
        isPast ? categoryColor.opacity(0.5) : categoryColor
    }

    private var backgroundColor: Color {
        effectiveColor.opacity(0.12)
    }

    private var shadowOpacity: Double {
        if isPast {
            return 0
        } else if isCurrent {
            return 0.15
        } else {
            return 0.1
        }
    }

    private var borderColor: Color {
        isCurrent ? effectiveColor : .clear
    }

    private var borderWidth: CGFloat {
        isCurrent ? 1.5 : 0
    }

    // MARK: - View

    var body: some View {
        ZStack(alignment: .leading) {
            // Background with category color
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                .fill(backgroundColor)

            // Left color strip (4pt)
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall)
                .fill(effectiveColor)
                .frame(width: 4)

            // Current event border glow
            if isCurrent {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                    .strokeBorder(borderColor, lineWidth: borderWidth)
                    .shadow(color: borderColor.opacity(isGlowing ? 0.6 : 0.3),
                            radius: isGlowing ? 6 : 3,
                            x: 0,
                            y: 0)
            }
        }
        .shadow(color: Color.black.opacity(shadowOpacity),
                radius: 4,
                x: 0,
                y: 2)
        .onAppear {
            if isCurrent {
                startGlowAnimation()
            }
        }
    }

    // MARK: - Private Methods

    private func startGlowAnimation() {
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            isGlowing = true
        }
    }
}

// MARK: - Preview

#Preview("Event Block Background - Past") {
    EventBlockBackground(
        categoryColor: Color(red: 66/255, green: 133/255, blue: 244/255),
        isPast: true,
        isCurrent: false
    )
    .frame(height: 80)
    .padding()
}

#Preview("Event Block Background - Current") {
    EventBlockBackground(
        categoryColor: Color(red: 251/255, green: 188/255, blue: 4/255),
        isPast: false,
        isCurrent: true
    )
    .frame(height: 80)
    .padding()
}

#Preview("Event Block Background - Future") {
    EventBlockBackground(
        categoryColor: Color(red: 199/255, green: 37/255, blue: 29/255),
        isPast: false,
        isCurrent: false
    )
    .frame(height: 80)
    .padding()
}
