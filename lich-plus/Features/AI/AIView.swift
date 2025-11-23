//
//  AIView.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 23/11/25.
//

import SwiftUI

struct AIView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("🤖 AI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                Spacer()

                VStack(spacing: 16) {
                    Text("AI Features")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    Text("Intelligent calendar and task recommendations")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("AI")
        }
    }
}

#Preview {
    AIView()
}
