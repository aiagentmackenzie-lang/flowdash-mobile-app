import SwiftUI

struct WelcomeView: View {
    let onGetStarted: () -> Void
    let onHaveKey: () -> Void
    @State private var boltScale: CGFloat = 0.3
    @State private var boltOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var buttonsOpacity: Double = 0
    @State private var pulseAmount: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0, 0], [0.5, 0], [1, 0],
                    [0, 0.5], [0.5, 0.5], [1, 0.5],
                    [0, 1], [0.5, 1], [1, 1]
                ],
                colors: [
                    .black, Color(.systemIndigo).opacity(0.3), .black,
                    Color(.systemIndigo).opacity(0.2), Color(.systemBlue).opacity(0.15), Color(.systemIndigo).opacity(0.2),
                    .black, Color(.systemIndigo).opacity(0.3), .black
                ]
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.blue.opacity(0.3), Color.clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(pulseAmount)

                    Image(systemName: "bolt.fill")
                        .font(.system(size: 72, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(boltScale)
                        .opacity(boltOpacity)
                }

                VStack(spacing: 8) {
                    Text("FlowDash")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Your N8N Workflows, In Your Pocket")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .opacity(titleOpacity)
                .padding(.top, 24)

                Spacer()

                VStack(spacing: 14) {
                    Button {
                        onGetStarted()
                    } label: {
                        Text("Get Started")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)

                    Button {
                        onHaveKey()
                    } label: {
                        Text("I Already Have a Key")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                }
                .opacity(buttonsOpacity)
                .padding(.horizontal, 24)
                .padding(.bottom, 60)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                boltScale = 1.0
                boltOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.6)) {
                titleOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(1.0)) {
                buttonsOpacity = 1.0
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(1.0)) {
                pulseAmount = 1.15
            }
        }
    }
}
