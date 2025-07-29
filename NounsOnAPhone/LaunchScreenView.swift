import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            // Full-screen vertical gradient background (matching landing page)
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.22, green: 0.60, blue: 0.98), Color(red: 0.20, green: 0.98, blue: 0.98)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()
                
                // Fish icon in rounded square (matching landing page)
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
                
                // Loading indicator (optional)
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                    
                    Text("Loading...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer(minLength: 40)
            }
        }
    }
}

#Preview {
    LaunchScreenView()
} 