import Foundation
import Combine

// MARK: - Timer Manager Protocol
protocol TimerManagerProtocol: ObservableObject {
    var timeRemaining: Int { get }
    var timerDuration: Int { get set }
    var isTimerRunning: Bool { get }
    
    func startTimer()
    func stopTimer()
    func updateTimerDuration(_ duration: Int)
    func resetTimer()
}

// MARK: - Timer Manager Delegate
protocol TimerManagerDelegate: AnyObject {
    func timerDidExpire()
}

// MARK: - Timer Manager Implementation
class TimerManager: ObservableObject, TimerManagerProtocol {
    @Published var timeRemaining: Int = 60
    @Published var timerDuration: Int = 60
    @Published var isTimerRunning: Bool = false
    
    private var timer: Timer?
    private let soundManager = SoundManager.shared
    
    // Delegate for timer expiration events
    weak var delegate: TimerManagerDelegate?
    
    init(duration: Int = 60) {
        self.timerDuration = duration
        self.timeRemaining = duration
    }
    
    func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timerExpired()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }
    
    func updateTimerDuration(_ duration: Int) {
        timerDuration = duration
        if !isTimerRunning {
            timeRemaining = duration
        }
    }
    
    func resetTimer() {
        stopTimer()
        timeRemaining = timerDuration
    }
    
    private func timerExpired() {
        stopTimer()
        soundManager.handleTimerExpired()
        delegate?.timerDidExpire()
    }
    
    deinit {
        stopTimer()
    }
} 