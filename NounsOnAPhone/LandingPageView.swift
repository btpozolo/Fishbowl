import SwiftUI

struct LandingPageView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Full-screen vertical gradient background
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.22, green: 0.60, blue: 0.98), Color(red: 0.20, green: 0.98, blue: 0.98)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()
                    // Fish icon in rounded square
                    ZStack {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.white.opacity(0.4), lineWidth: 2)
                            .background(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .fill(Color.white.opacity(0.12))
                            )
                            .frame(width: 120, height: 120)
                        Text("🐟")
                            .font(.system(size: 56))
                            .accessibilityLabel("Fishbowl app icon")
                    }
                    // App name
                    Text("Fishbowl")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .accessibilityAddTraits(.isHeader)
                    // Subtitle
                    Text("The ultimate party game for groups")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    Spacer()
                    // Buttons
                    VStack(spacing: 20) {
                        NavigationLink(destination: SetupView(gameState: gameState)) {
                            Text("Start New Game")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                        }
                        .accessibilityLabel("Start New Game")
                        NavigationLink(destination: HowToPlayView()) {
                            Text("How to Play")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.7), lineWidth: 2)
                                )
                        }
                        .accessibilityLabel("How to Play")
                    }
                    .padding(.horizontal, 32)
                    Spacer(minLength: 40)
                }
            }
        }
        .onAppear {
            // Force portrait orientation when the view appears
            DispatchQueue.main.async {
                OrientationManager.shared.lock(to: .portrait)
            }
        }
        .onDisappear {
            // Reset to allow all orientations when leaving this view
            DispatchQueue.main.async {
                OrientationManager.shared.lock(to: [.portrait, .landscapeLeft, .landscapeRight])
            }
        }
    }
}

struct LandingPageView_Previews: PreviewProvider {
    static var previews: some View {
        LandingPageView(gameState: GameState())
    }
} 