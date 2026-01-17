//
//  GreetingsView.swift
//  lich-plus
//
//  Created by Claude on 17/01/26.
//

import SwiftUI

/// Main view for the Greetings tab
struct GreetingsView: View {
    var body: some View {
        NavigationStack {
            GreetingGeneratorView()
                .navigationTitle(String(localized: "tab.greetings"))
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Preview

#Preview {
    GreetingsView()
}
