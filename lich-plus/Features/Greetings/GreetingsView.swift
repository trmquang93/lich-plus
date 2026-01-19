//
//  GreetingsView.swift
//  lich-plus
//

import SwiftUI

/// Main view for the Greetings tab
struct GreetingsView: View {
    var body: some View {
        NavigationStack {
            GreetingGeneratorView()
                .navigationTitle(String(localized: "Greetings"))
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Preview

#Preview {
    GreetingsView()
}
