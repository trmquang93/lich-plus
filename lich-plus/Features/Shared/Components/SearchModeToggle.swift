//
//  SearchModeToggle.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 27/11/25.
//

import SwiftUI

struct SearchModeToggle: View {
    @Binding var isAIMode: Bool

    var body: some View {
        Picker("search.mode", selection: $isAIMode) {
            Label("search.mode.text", systemImage: "textformat.abc")
                .tag(false)

            Label("search.mode.ai", systemImage: "sparkles")
                .tag(true)
        }
        .pickerStyle(.segmented)
        .frame(width: 100)
    }
}

#Preview {
    SearchModeToggle(isAIMode: .constant(false))
}
