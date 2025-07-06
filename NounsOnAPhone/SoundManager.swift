import AVFoundation
import SwiftUI

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var effectPlayer: AVAudioPlayer?
    
    // Control properties
    @Published var isBackgroundMusicEnabled = true
    @Published var isSoundEffectsEnabled = true
    @Published var backgroundMusicVolume: Float = 0.3
    @Published var soundEffectsVolume: Float = 0.7
    
    private init() {
        setupAudioSession()
    }
    
    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - Background Music
    func startBackgroundMusic() {
        guard isBackgroundMusicEnabled else { return }
        
        // Stop any existing background music
        stopBackgroundMusic()
        
        guard let url = Bundle.main.url(forResource: "clock_tick_old", withExtension: "wav") else {
            print("Background music file not found")
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.volume = backgroundMusicVolume
            backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundMusicPlayer?.play()
        } catch {
            print("Failed to play background music: \(error)")
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
    }
    
    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
    }
    
    func resumeBackgroundMusic() {
        guard isBackgroundMusicEnabled else { return }
        backgroundMusicPlayer?.play()
    }
    
    // MARK: - Sound Effects
    func playTimeUpSound() {
        guard isSoundEffectsEnabled else { return }
        
        guard let url = Bundle.main.url(forResource: "final_triple_buzz_mechanical", withExtension: "wav") else {
            print("Time up sound file not found")
            return
        }
        
        do {
            effectPlayer = try AVAudioPlayer(contentsOf: url)
            effectPlayer?.volume = soundEffectsVolume
            effectPlayer?.play()
        } catch {
            print("Failed to play time up sound: \(error)")
        }
    }
    
    // MARK: - Volume Controls
    func updateBackgroundMusicVolume() {
        backgroundMusicPlayer?.volume = backgroundMusicVolume
    }
    
    func updateSoundEffectsVolume() {
        // This will apply to the next sound effect played
    }
    
    // MARK: - Settings Management
    func toggleBackgroundMusic() {
        isBackgroundMusicEnabled.toggle()
        isSoundEffectsEnabled = isBackgroundMusicEnabled // Sync both settings
        if isBackgroundMusicEnabled {
            resumeBackgroundMusic()
        } else {
            pauseBackgroundMusic()
        }
    }
    
    func toggleSoundEffects() {
        isSoundEffectsEnabled.toggle()
    }
    
    func toggleAllSounds() {
        isBackgroundMusicEnabled.toggle()
        isSoundEffectsEnabled = isBackgroundMusicEnabled
        if isBackgroundMusicEnabled {
            resumeBackgroundMusic()
        } else {
            pauseBackgroundMusic()
        }
    }
    
    // MARK: - Game State Integration
    func handleGamePhaseChange(to phase: GamePhase) {
        switch phase {
        case .playing:
            startBackgroundMusic()
        case .roundTransition, .gameOver, .setup, .wordInput, .gameOverview:
            stopBackgroundMusic()
        }
    }
    
    func handleTimerExpired() {
        playTimeUpSound()
    }
} 
