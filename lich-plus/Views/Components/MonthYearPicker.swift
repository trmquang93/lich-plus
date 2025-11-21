import SwiftUI

// MARK: - Month Year Picker Navigation Header
struct MonthYearPicker: View {
    @Binding var currentDate: Date
    let onPreviousMonth: () -> Void
    let onNextMonth: () -> Void

    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "vi_VN")
        let text = formatter.string(from: currentDate)
        // Capitalize first letter for Vietnamese
        return text.prefix(1).uppercased() + text.dropFirst()
    }

    var body: some View {
        HStack(spacing: 16) {
            // Previous Month Button
            Button(action: onPreviousMonth) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "#5BC0A6") ?? .green)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }

            Spacer()

            // Month Year Display
            VStack(spacing: 4) {
                Text(monthYearString)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)

                Text("Tháng \(Calendar.current.component(.month, from: currentDate))/\(Calendar.current.component(.year, from: currentDate))")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.gray)
            }

            Spacer()

            // Next Month Button
            Button(action: onNextMonth) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "#5BC0A6") ?? .green)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Preview
#Preview {
    VStack {
        MonthYearPicker(
            currentDate: .constant(Date()),
            onPreviousMonth: {},
            onNextMonth: {}
        )
        Spacer()
    }
    .background(Color.gray.opacity(0.1))
}
