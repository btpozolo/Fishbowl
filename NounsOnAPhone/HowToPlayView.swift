import SwiftUI

struct HowToPlayView: View {
    var body: some View {
        ZStack {
            // Full-screen vertical gradient background (matching landing page)
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.22, green: 0.60, blue: 0.98), Color(red: 0.20, green: 0.98, blue: 0.98)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Game Overview
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Game Overview")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Fishbowl is a fun party game where teams take turns guessing words through three exciting rounds. Each round has different rules for how you can help your team guess the words!")
                            .font(.body)
                            .foregroundColor(.black.opacity(0.8))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
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
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Round Descriptions
                    VStack(spacing: 16) {
                        ForEach(RoundType.allCases, id: \.rawValue) { round in
                            RoundInstructionCard(round: round)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Setup Instructions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Getting Started")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            InstructionStep(number: "1", title: "Set Up", description: "Choose your timer duration and enable/disable skip functionality")
                            InstructionStep(number: "2", title: "Add Words", description: "Enter at least 3 words that everyone in your group knows")
                            InstructionStep(number: "3", title: "Review Rules", description: "Read through the three rounds and their specific rules")
                            InstructionStep(number: "4", title: "Start Playing", description: "Teams take turns with the timer running")
                        }
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
                    .padding(.horizontal, 20)
                    
                    // Tips Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Pro Tips")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            TipItem(text: "Use words that everyone in your group is familiar with")
                            TipItem(text: "For Round 2, practice your acting skills beforehand")
                            TipItem(text: "In Round 3, choose your one word carefully - it's your only chance!")
                            TipItem(text: "Don't be afraid to skip difficult words if enabled")
                        }
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
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("How to Play")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.clear, for: .navigationBar)
        .onAppear {
            OrientationManager.shared.lock(to: .portrait)
        }
        .onDisappear {
            // Reset to allow all orientations when leaving this view
            OrientationManager.shared.lock(to: [.portrait, .landscapeLeft, .landscapeRight])
        }
    }
}

// MARK: - Supporting Views
struct RoundInstructionCard: View {
    let round: RoundType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(round.title)
                .font(.headline)
                .foregroundColor(.black)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(round.description)
                .font(.subheadline)
                .foregroundColor(.black.opacity(0.8))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.35))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct InstructionStep: View {
    let number: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 28, height: 28)
                Text(number)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.8))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct TipItem: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundColor(.black)
                .padding(.top, 2)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.black.opacity(0.8))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    NavigationStack {
        HowToPlayView()
    }
} 
