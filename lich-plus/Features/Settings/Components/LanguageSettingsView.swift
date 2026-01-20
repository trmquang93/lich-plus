//
//  LanguageSettingsView.swift
//  lich-plus
//

import SwiftUI

struct LanguageSettingsView: View {
    @State private var showRestartAlert = false

    var body: some View {
        List {
            ForEach(AppLanguage.allCases) { language in
                HStack {
                    Text(language.flag)
                        .font(.title)

                    Text(language.nativeName)
                        .font(.body)
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()

                    if LanguageManager.shared.currentLanguage == language {
                        Image(systemName: "checkmark")
                            .foregroundStyle(AppColors.primary)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if LanguageManager.shared.currentLanguage != language {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            LanguageManager.shared.setLanguage(language)
                        }
                        showRestartAlert = true
                    }
                }
            }
        }
        .navigationTitle(String(localized: "Language Settings"))
        .alert(String(localized: "Language Changed"), isPresented: $showRestartAlert) {
            Button(String(localized: "OK"), role: .cancel) { }
        } message: {
            Text(String(localized: "Please restart the app to apply the language change."))
        }
    }
}

#Preview {
    NavigationStack {
        LanguageSettingsView()
    }
}
