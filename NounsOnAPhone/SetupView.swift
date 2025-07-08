import SwiftUI

struct SetupView: View {
    @ObservedObject var gameState: GameState
    @ObservedObject private var soundManager = SoundManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Header
                VStack(spacing: 16) {
                    Text("Fishbowl")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("Game Setup")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Timer configuration card
                VStack(spacing: 24) {
                    HStack {
                        Image(systemName: "timer")
                            .font(.title)
                            .foregroundColor(.accentColor)
                        
                        Text("Timer Duration")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(gameState.timerDuration)s")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.accentColor.opacity(0.15))
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
                        .accentColor(.accentColor)
                        
                        HStack {
                            Text("10s")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("120s")
                                .font(.caption)
                                .foregroundColor(.secondary)
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
                                    .foregroundColor(gameState.timerDuration == duration ? .white : .accentColor)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(gameState.timerDuration == duration ? Color.accentColor : Color.accentColor.opacity(0.1))
                                    )
                            }
                        }
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                )
                .padding(.horizontal, 20)

                // Skip Button Setting
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "arrowshape.turn.up.right")
                            .font(.title)
                            .foregroundColor(.accentColor)
                        Text("Enable Skip")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Spacer()
                        Toggle("", isOn: $gameState.skipEnabled)
                            .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                    }
                    Text("Allow players to skip a word during gameplay. Skipped words will return later in the round.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 0)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                )
                .padding(.horizontal, 20)
                
                // Simplified Sound Settings
                VStack(spacing: 24) {
                    HStack {
                        Image(systemName: "speaker.wave.3")
                            .font(.title)
                            .foregroundColor(.accentColor)
                        
                        Text("Sound Settings")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    VStack(spacing: 16) {
                        // Single Sound Toggle
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Enable Sounds")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Background music and timer alerts")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $soundManager.isBackgroundMusicEnabled)
                                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                .onChange(of: soundManager.isBackgroundMusicEnabled) { newValue in
                                    soundManager.isSoundEffectsEnabled = newValue
                                }
                        }
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                )
                .padding(.horizontal, 20)
                
                // Proceed to word input button
                GameButton.primary(
                    title: "Input Words",
                    icon: nil,
                    size: .large
                ) {
                    withAnimation(.spring(response: 0.6)) {
                        gameState.proceedToWordInput()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color(.systemBackground).opacity(0.95)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

#Preview {
    SetupView(gameState: GameState())
} 
