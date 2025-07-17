import SwiftUI

struct SetupView: View {
    @ObservedObject var gameState: GameState
    @ObservedObject private var soundManager = SoundManager.shared
    @Environment(\.dismiss) private var dismiss
    
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
    
    // Extracted timer card
    private var timerCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Timer Duration")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("\(gameState.timerDuration)s")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(12)
            }
            
            VStack(spacing: 12) {
                Slider(
                    value: Binding(
                        get: { Double(gameState.timerDuration) },
                        set: { gameState.timerDuration = Int($0) }
                    ),
                    in: 10...120,
                    step: 5
                )
                .accentColor(Color(red: 0.22, green: 0.60, blue: 0.98))
                
                HStack {
                    Text("10s")
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.6))
                    
                    Spacer()
                    
                    Text("120s")
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.6))
                }
            }
            
            // Quick preset buttons
            HStack(spacing: 12) {
                ForEach([30, 60, 90], id: \.self) { duration in
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            gameState.timerDuration = duration
                        }
                    }) {
                        Text("\(duration)s")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(gameState.timerDuration == duration ? .white : Color(red: 0.22, green: 0.60, blue: 0.98))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(gameState.timerDuration == duration ? Color(red: 0.22, green: 0.60, blue: 0.98) : Color(red: 0.22, green: 0.60, blue: 0.98).opacity(0.1))
                            )
                    }
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(cardBackground)
        .padding(.horizontal, 20)
    }
    
    // Extracted skip card
    private var skipCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Enable Skip")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Toggle("", isOn: $gameState.skipEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.22, green: 0.60, blue: 0.98)))
            }
            
            Text("Allow players to skip a word during gameplay. Skipped words will return later in the round.")
                .font(.subheadline)
                .foregroundColor(.black.opacity(0.8))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(cardBackground)
        .padding(.horizontal, 20)
    }
    
    // Extracted sound settings card
    private var soundSettingsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sound Settings")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Enable Sounds")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Background music and timer alerts")
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Toggle("", isOn: $soundManager.isBackgroundMusicEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.22, green: 0.60, blue: 0.98)))
                        .onChange(of: soundManager.isBackgroundMusicEnabled) { oldValue, newValue in
                            soundManager.isSoundEffectsEnabled = newValue
                        }
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(cardBackground)
        .padding(.horizontal, 20)
    }
    
    // Extracted input words button
    private var inputWordsButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.6)) {
                gameState.proceedToWordInput()
            }
        }) {
            Text("Input Words")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(16)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        timerCard
                        skipCard
                        soundSettingsCard
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 20)
                }
                
                inputWordsButton
            }
        }
        .navigationTitle("Game Setup")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Game Setup")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .navigationBarBackButtonHidden(true)

        .onAppear {
            OrientationManager.shared.lock(to: .portrait)
        }
        .onDisappear {
            // Reset to allow all orientations when leaving this view
            OrientationManager.shared.lock(to: [.portrait, .landscapeLeft, .landscapeRight])
        }
    }
}

#Preview {
    NavigationStack {
        SetupView(gameState: GameState())
    }
} 
