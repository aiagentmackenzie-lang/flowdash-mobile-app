import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var currentPage = 0

    private let slides: [(icon: String, title: String, subtitle: String)] = [
        ("link.circle.fill", "Connect Your Instance", "Connect your N8N instance in seconds"),
        ("eye.circle.fill", "Monitor Live", "Monitor all your workflows live"),
        ("play.circle.fill", "Trigger Anywhere", "Trigger workflows right from your phone")
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    if currentPage < slides.count - 1 {
                        Button("Skip") {
                            onComplete()
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .frame(height: 44)

                TabView(selection: $currentPage) {
                    ForEach(Array(slides.enumerated()), id: \.offset) { index, slide in
                        VStack(spacing: 24) {
                            Spacer()

                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 140, height: 140)

                                Image(systemName: slide.icon)
                                    .font(.system(size: 64))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.blue, .cyan],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }

                            VStack(spacing: 12) {
                                Text(slide.title)
                                    .font(.title.bold())
                                    .foregroundStyle(.white)

                                Text(slide.subtitle)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }

                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                VStack(spacing: 24) {
                    HStack(spacing: 8) {
                        ForEach(0..<slides.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? Color.blue : Color.white.opacity(0.2))
                                .frame(width: index == currentPage ? 24 : 8, height: 8)
                                .animation(.snappy, value: currentPage)
                        }
                    }

                    if currentPage == slides.count - 1 {
                        Button {
                            onComplete()
                        } label: {
                            Text("Let's Connect")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .padding(.horizontal, 24)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    } else {
                        Button {
                            withAnimation(.snappy) {
                                currentPage += 1
                            }
                        } label: {
                            Text("Next")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.bottom, 60)
                .animation(.snappy, value: currentPage)
            }
        }
        .preferredColorScheme(.dark)
    }
}
