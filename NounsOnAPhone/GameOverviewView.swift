import SwiftUI

struct GameOverviewView: View {
    @ObservedObject var gameState: GameState
    
    // Extracted background gradient
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color(red: 0.22, green: 0.60, blue: 0.98), Color(red: 0.20, green: 0.98, blue: 0.98)]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // Extracted card background style
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white.opacity(0.35))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header section
                VStack(spacing: 16) {
                    
                    // Title and subtitle
                    VStack(spacing: 8) {
                        Text("Game Overview")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("\(gameState.wordManager.words.count) words ready to play!")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // Main content area
                ScrollView {
                    VStack(spacing: 20) {
                        // Timer info card
                        VStack(spacing: 16) {
                            HStack(spacing: 12) {
                                Image(systemName: "timer")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                
                                Text("\(gameState.timerManager.timerDuration) seconds per team")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(cardBackground)
                        .padding(.horizontal, 20)
                        
                        // Round descriptions
                        VStack(spacing: 16) {
                            ForEach(RoundType.allCases, id: \.rawValue) { round in
                                RoundDescriptionCard(round: round)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 20)
                }
                
                // Ready to Begin button
                Button(action: {
                    withAnimation(.spring(response: 0.6)) {
                        gameState.beginRound()
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                        Text("Ready to Begin!")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.22, green: 0.60, blue: 0.98))
                    .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            OrientationManager.shared.lock(to: .portrait)
        }
        .onDisappear {
            OrientationManager.shared.lock(to: [.portrait, .landscapeLeft, .landscapeRight])
        }
    }
}

// MARK: - Round Description Card
struct RoundDescriptionCard: View {
    let round: RoundType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(roundColor)
                        .frame(width: 40, height: 40)
                    Text("\(round.rawValue)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(round.title)
                        .font(.headline)
                        .foregroundColor(.black)
                        .fontWeight(.semibold)
                    Text(round.description)
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.8))
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack {
                Image(systemName: roundIcon)
                    .font(.title3)
                    .foregroundColor(roundColor)
                Text(roundTip)
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.7))
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(roundColor.opacity(0.1))
            )
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.35))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var roundColor: Color {
        switch round {
        case .describe:
            return .blue
        case .actOut:
            return .orange
        case .oneWord:
            return .purple
        }
    }
    
    private var roundIcon: String {
        switch round {
        case .describe:
            return "text.bubble"
        case .actOut:
            return "person.fill"
        case .oneWord:
            return "1.circle"
        }
    }
    
    private var roundTip: String {
        switch round {
        case .describe:
            return "Use descriptions, synonyms, or related words"
        case .actOut:
            return "Use gestures, facial expressions, and body language"
        case .oneWord:
            return "Only one word allowed - choose carefully!"
        }
    }
}

#Preview {
    GameOverviewView(gameState: GameState())
}
