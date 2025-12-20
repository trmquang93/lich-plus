//
//  NowIndicator.swift
//  lich-plus
//
//  Created by Quang Tran Minh on 13/12/25.
//

import SwiftUI
import Combine

struct NowIndicator: View {
    @State private var pulseScale: CGFloat = 1.0
    @State private var currentTime: Date = Date()
    @State private var timerCancellable: AnyCancellable?

    var timer: Publishers.Autoconnect<Timer.TimerPublisher> {
        Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: currentTime)
    }

    var body: some View {
        VStack(spacing: AppTheme.spacing4) {
            // Time label centered horizontally
            Text(timeString)
                .font(.system(size: AppTheme.fontCaption, weight: .medium))
                .foregroundColor(AppColors.primary)
                .frame(maxWidth: .infinity, alignment: .center)

            // Circle with line indicator
            ZStack(alignment: .leading) {
                // Full-width line with glow effect
                Rectangle()
                    .fill(AppColors.primary)
                    .frame(height: 2)
                    .shadow(color: AppColors.primary.opacity(0.3), radius: 4, x: 0, y: 0)

                // Pulsing circle on the left
                Circle()
                    .fill(AppColors.primary)
                    .frame(width: 12, height: 12)
                    .scaleEffect(pulseScale)
            }
            .frame(height: 12) // Height to accommodate the circle
        }
        .onAppear {
            startPulseAnimation()
            // Update current time on appearance
            currentTime = Date()
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }

    private func startPulseAnimation() {
        // Spring animation with organic feel, repeating forever
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).repeatForever(autoreverses: true)) {
            pulseScale = 1.3
        }
    }
}

#Preview("NowIndicator - Standalone") {
    VStack(spacing: AppTheme.spacing16) {
        Text("Standalone NowIndicator")
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()

        NowIndicator()
            .padding(.horizontal, AppTheme.spacing16)

        Spacer()
    }
    .background(AppColors.background)
}

#Preview("NowIndicator - In Timeline Context") {
    ZStack(alignment: .topLeading) {
        // Timeline background with hour markers
        VStack(spacing: 0) {
            ForEach(0..<24, id: \.self) { hour in
                HStack(spacing: AppTheme.spacing8) {
                    Text("\(String(format: "%02d", hour)):00")
                        .font(.system(size: AppTheme.fontCaption, weight: .regular))
                        .foregroundColor(.gray)
                        .frame(width: 40)

                    Divider()
                        .opacity(0.3)
                }
                .frame(height: 60)
            }
        }
        .padding(.leading, AppTheme.spacing16)

        // NowIndicator positioned at current time
        NowIndicator()
            .padding(.horizontal, AppTheme.spacing16)
            .offset(y: calculateNowIndicatorOffset())
    }
    .frame(height: 600)
    .background(AppColors.background)
}

private func calculateNowIndicatorOffset() -> CGFloat {
    let calendar = Calendar.current
    let now = Date()
    let hour = CGFloat(calendar.component(.hour, from: now))
    let minute = CGFloat(calendar.component(.minute, from: now))

    // Each hour is 60pt in height, so calculate offset
    return (hour * 60 + minute)
}
