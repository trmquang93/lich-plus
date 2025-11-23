//
//  Theme.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import SwiftUI

struct AppColors {
    // MARK: - Primary Colors

    /// Primary red used for weekends, highlights, and active states
    /// RGB: (199, 37, 29)
    static let primary = Color(red: 199/255, green: 37/255, blue: 29/255)

    /// Dark red for pressed/focused states
    static let primaryDark = Color(red: 169/255, green: 28/255, blue: 21/255)

    // MARK: - Secondary Colors

    /// Gray used for inactive tabs and secondary text
    /// RGB: (153, 153, 153)
    static let secondary = Color(red: 153/255, green: 153/255, blue: 153/255)

    /// Light gray for borders and dividers
    static let borderLight = Color(red: 224/255, green: 224/255, blue: 224/255)

    // MARK: - Accent Colors

    /// Green for event indicators and positive actions
    /// RGB: (76, 175, 80)
    static let accent = Color(red: 76/255, green: 175/255, blue: 80/255)

    /// Light green background
    static let accentLight = Color(red: 232/255, green: 245/255, blue: 233/255)

    // MARK: - Event Colors

    /// Orange/Red event indicator
    static let eventOrange = Color(red: 255/255, green: 152/255, blue: 0/255)

    /// Blue event indicator
    static let eventBlue = Color(red: 66/255, green: 133/255, blue: 244/255)

    /// Yellow event indicator
    static let eventYellow = Color(red: 251/255, green: 188/255, blue: 4/255)

    /// Pink/Mauve event background
    static let eventPink = Color(red: 248/255, green: 187/255, blue: 208/255)

    // MARK: - Background Colors

    /// Primary background (white)
    static let background = Color(red: 255/255, green: 255/255, blue: 255/255)

    /// Light pink/cream background for date cells
    static let backgroundLight = Color(red: 251/255, green: 233/255, blue: 231/255)

    /// Very light gray background
    static let backgroundLightGray = Color(red: 245/255, green: 245/255, blue: 245/255)

    // MARK: - Text Colors

    /// Primary text color (black)
    static let textPrimary = Color(red: 26/255, green: 26/255, blue: 26/255)

    /// Secondary text color (dark gray)
    static let textSecondary = Color(red: 117/255, green: 117/255, blue: 117/255)

    /// Light gray text for dates from other months
    static let textDisabled = Color(red: 204/255, green: 204/255, blue: 204/255)

    // MARK: - System Colors

    static let white = Color.white
    static let black = Color.black
    static let clear = Color.clear
}

// MARK: - Color Extensions for convenient access

extension Color {
    static let appPrimary = AppColors.primary
    static let appSecondary = AppColors.secondary
    static let appAccent = AppColors.accent
    static let appBackground = AppColors.background
    static let appTextPrimary = AppColors.textPrimary
    static let appTextSecondary = AppColors.textSecondary

    var uiColor: UIColor {
        UIColor(self)
    }
}

// MARK: - Design System

struct AppTheme {
    // MARK: - Spacing

    static let spacing2: CGFloat = 2
    static let spacing4: CGFloat = 4
    static let spacing8: CGFloat = 8
    static let spacing12: CGFloat = 12
    static let spacing16: CGFloat = 16
    static let spacing20: CGFloat = 20
    static let spacing24: CGFloat = 24

    // MARK: - Corner Radius

    static let cornerRadiusSmall: CGFloat = 4
    static let cornerRadiusMedium: CGFloat = 8
    static let cornerRadiusLarge: CGFloat = 12
    static let cornerRadiusXL: CGFloat = 16

    // MARK: - Font Sizes

    static let fontCaption: CGFloat = 12
    static let fontBody: CGFloat = 14
    static let fontSubheading: CGFloat = 16
    static let fontTitle3: CGFloat = 18
    static let fontTitle2: CGFloat = 22
    static let fontTitle1: CGFloat = 28

    // MARK: - Opacity Values

    static let opacityDisabled: Double = 0.5
    static let opacityPressed: Double = 0.7
    static let opacityHovered: Double = 0.85
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 12) {
            VStack {
                Color.appPrimary
                    .frame(height: 60)
                Text("Primary")
                    .font(.caption)
            }
            VStack {
                Color.appSecondary
                    .frame(height: 60)
                Text("Secondary")
                    .font(.caption)
            }
            VStack {
                Color.appAccent
                    .frame(height: 60)
                Text("Accent")
                    .font(.caption)
            }
        }

        HStack(spacing: 12) {
            VStack {
                AppColors.eventOrange
                    .frame(height: 60)
                Text("Orange")
                    .font(.caption)
            }
            VStack {
                AppColors.eventBlue
                    .frame(height: 60)
                Text("Blue")
                    .font(.caption)
            }
            VStack {
                AppColors.eventYellow
                    .frame(height: 60)
                Text("Yellow")
                    .font(.caption)
            }
        }

        HStack(spacing: 12) {
            VStack {
                AppColors.backgroundLight
                    .frame(height: 60)
                Text("BG Light")
                    .font(.caption)
            }
            VStack {
                AppColors.accentLight
                    .frame(height: 60)
                Text("Accent Light")
                    .font(.caption)
            }
            VStack {
                AppColors.eventPink
                    .frame(height: 60)
                Text("Pink")
                    .font(.caption)
            }
        }
    }
    .padding()
}
