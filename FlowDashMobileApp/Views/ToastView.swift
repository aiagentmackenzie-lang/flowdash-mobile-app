import SwiftUI

struct ToastView: View {
    let message: String
    let isError: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                .foregroundStyle(isError ? .red : .green)

            Text(message)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)
                .lineLimit(2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(.capsule)
        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
        .padding(.horizontal, 24)
    }
}
