//
//  GreetingsView.swift
//  lich-plus
//

import SwiftUI

/// Main view for the Greetings tab
struct GreetingsView: View {
    @State private var currentYear = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        NavigationStack {
            GreetingGeneratorView()
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack(spacing: 2) {
                            Text(String(localized: "Tet Greetings") + " \(GreetingOccasion.canChi(for: currentYear))")
                                .font(.system(size: AppTheme.fontTitle2, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text(String(localized: "Year of") + " \(GreetingOccasion.zodiacAnimal(for: currentYear))")
                                .font(.system(size: AppTheme.fontBody))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
        }
    }
}

// MARK: - Preview

#Preview {
    GreetingsView()
}
