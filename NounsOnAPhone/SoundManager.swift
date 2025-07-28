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
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            print("Audio session setup successful")
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - Background Music
    func startBackgroundMusic() {
        guard isBackgroundMusicEnabled else { 
            print("Background music disabled")
            return 
        }
        
        print("Starting background music...")
        
        // Stop any existing background music
        stopBackgroundMusic()
        
        // Try with subdirectory first
        var url = Bundle.main.url(forResource: "clock_tick_old", withExtension: "wav", subdirectory: "Sounds")
        
        // If not found, try without subdirectory
        if url == nil {
            url = Bundle.main.url(forResource: "clock_tick_old", withExtension: "wav")
        }
        
        guard let finalUrl = url else {
            print("Background music file not found")
            return
        }
        
        print("Background music URL: \(finalUrl)")
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: finalUrl)
            backgroundMusicPlayer?.volume = backgroundMusicVolume
            backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundMusicPlayer?.play()
            print("Background music started successfully")
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
        guard isSoundEffectsEnabled else { 
            print("Sound effects disabled")
            return 
        }
        
        print("Playing time up sound...")
        
        // Try with subdirectory first
        var url = Bundle.main.url(forResource: "2_gentle_pulse_high_pitch", withExtension: "wav", subdirectory: "Sounds")
        
        // If not found, try without subdirectory
        if url == nil {
            url = Bundle.main.url(forResource: "2_gentle_pulse_high_pitch", withExtension: "wav")
        }
        
        guard let finalUrl = url else {
            print("Time up sound file not found")
            return
        }
        
        print("Time up sound URL: \(finalUrl)")
        
        do {
            effectPlayer = try AVAudioPlayer(contentsOf: finalUrl)
            effectPlayer?.volume = soundEffectsVolume
            effectPlayer?.play()
            print("Time up sound played successfully")
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
        let newState = !isBackgroundMusicEnabled
        isBackgroundMusicEnabled = newState
        isSoundEffectsEnabled = newState
        if newState {
            resumeBackgroundMusic()
        } else {
            pauseBackgroundMusic()
        }
    }
    
    // MARK: - Game State Integration
    func handleGamePhaseChange(to phase: GamePhase) {
        print("Game phase changed to: \(phase)")
        switch phase {
        case .playing:
            startBackgroundMusic()
        case .roundTransition, .gameOver, .setup, .setupView, .wordInput, .gameOverview:
            stopBackgroundMusic()
        }
    }
    
    func handleTimerExpired() {
        print("Timer expired - playing time up sound")
        playTimeUpSound()
    }
    
    // MARK: - Debug Functions
    func testBackgroundMusic() {
        print("Testing background music...")
        startBackgroundMusic()
    }
    
    func testTimeUpSound() {
        print("Testing time up sound...")
        playTimeUpSound()
    }
} 
