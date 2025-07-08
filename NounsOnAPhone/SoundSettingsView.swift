import SwiftUI

struct SoundSettingsView: View {
    @ObservedObject private var soundManager = SoundManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Background Music Section
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "music.note")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                        
                        Text("Background Music")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    VStack(spacing: 16) {
                        // Toggle
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Enable Background Music")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Ambient music during gameplay")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $soundManager.isBackgroundMusicEnabled)
                                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                        }
                        
                        // Volume Control
                        if soundManager.isBackgroundMusicEnabled {
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Volume")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(Int(soundManager.backgroundMusicVolume * 100))%")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Slider(
                                    value: $soundManager.backgroundMusicVolume,
                                    in: 0.0...1.0,
                                    step: 0.1
                                )
                                .accentColor(.accentColor)
                                .onChange(of: soundManager.backgroundMusicVolume) { oldValue, newValue in
                                    soundManager.updateBackgroundMusicVolume()
                                }
                            }
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                )
                
                // Sound Effects Section
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "speaker.wave.2")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                        
                        Text("Sound Effects")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    VStack(spacing: 16) {
                        // Toggle
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Enable Sound Effects")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Timer alerts and game sounds")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $soundManager.isSoundEffectsEnabled)
                                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                        }
                        
                        // Volume Control
                        if soundManager.isSoundEffectsEnabled {
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Volume")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(Int(soundManager.soundEffectsVolume * 100))%")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Slider(
                                    value: $soundManager.soundEffectsVolume,
                                    in: 0.0...1.0,
                                    step: 0.1
                                )
                                .accentColor(.accentColor)
                            }
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                )
                
                Spacer()
            }
            .padding(20)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Sound Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SoundSettingsView()
} 