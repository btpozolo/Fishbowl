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
        } catch {
            // Audio session setup failed - app will continue without audio
        }
    }
    
    // MARK: - Background Music
    func startBackgroundMusic() {
        guard isBackgroundMusicEnabled else { 
            return 
        }
        
        // Stop any existing background music
        stopBackgroundMusic()
        
        // Try with subdirectory first
        var url = Bundle.main.url(forResource: "clock_tick_old", withExtension: "wav", subdirectory: "Sounds")
        
        // If not found, try without subdirectory
        if url == nil {
            url = Bundle.main.url(forResource: "clock_tick_old", withExtension: "wav")
        }
        
        guard let finalUrl = url else {
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: finalUrl)
            backgroundMusicPlayer?.volume = backgroundMusicVolume
            backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundMusicPlayer?.play()
        } catch {
            // Background music failed to start - app will continue without audio
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
            return 
        }
        
        // Try with subdirectory first
        var url = Bundle.main.url(forResource: "2_gentle_pulse_high_pitch", withExtension: "wav", subdirectory: "Sounds")
        
        // If not found, try without subdirectory
        if url == nil {
            url = Bundle.main.url(forResource: "2_gentle_pulse_high_pitch", withExtension: "wav")
        }
        
        guard let finalUrl = url else {
            return
        }
        
        do {
            effectPlayer = try AVAudioPlayer(contentsOf: finalUrl)
            effectPlayer?.volume = soundEffectsVolume
            effectPlayer?.play()
        } catch {
            // Time up sound failed to play - app will continue without audio
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
        switch phase {
        case .playing:
            startBackgroundMusic()
        case .roundTransition, .gameOver, .setup, .setupView, .wordInput, .gameOverview:
            stopBackgroundMusic()
        }
    }
    
    func handleTimerExpired() {
        playTimeUpSound()
    }
    
    // MARK: - Debug Functions
    func testBackgroundMusic() {
        startBackgroundMusic()
    }
    
    func testTimeUpSound() {
        playTimeUpSound()
    }
} 
