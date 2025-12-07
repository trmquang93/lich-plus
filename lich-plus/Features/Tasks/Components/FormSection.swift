//
//  FormSection.swift
//  lich-plus
//
//  Form section component with title and content
//

import SwiftUI

struct FormSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            Text(title)
                .font(.system(size: AppTheme.fontBody, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)

            content
        }
    }
}
