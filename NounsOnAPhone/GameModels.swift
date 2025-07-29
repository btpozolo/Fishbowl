import Foundation
import Combine

// MARK: - Game Models
struct Word: Identifiable, Hashable {
    let id = UUID()
    let text: String
    var used: Bool = false
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Word, rhs: Word) -> Bool {
        lhs.id == rhs.id
    }
}

enum GamePhase {
    case setup
    case setupView
    case wordInput
    case gameOverview
    case playing
    case roundTransition
    case gameOver
}

enum RoundType: Int, CaseIterable {
    case describe = 1
    case actOut = 2
    case oneWord = 3
    
    var title: String {
        switch self {
        case .describe:
            return "Round 1: Describe the Word"
        case .actOut:
            return "Round 2: Act Out the Word"
        case .oneWord:
            return "Round 3: One Word Only"
        }
    }
    
    var description: String {
        switch self {
        case .describe:
            return "Describe the word without saying the word itself"
        case .actOut:
            return "Act out the word using gestures and body language"
        case .oneWord:
            return "Describe the word using only one word"
        }
    }
    
    var shortDescription: String {
        switch self {
        case .describe:
            return "Describe"
        case .actOut:
            return "Act Out"
        case .oneWord:
            return "One Word"
        }
    }
}

enum TransitionReason {
    case timerExpired
    case wordsExhausted
}

class GameState: ObservableObject {
    // GameCoordinator handles all game logic
    private let gameCoordinator = GameCoordinator()
    
    // Published properties that delegate to GameCoordinator
    @Published var currentPhase: GamePhase = .setup
    
    // Published properties that relay manager state for UI binding
    @Published var wordCount: Int = 0
    @Published var canStartGame: Bool = false
    @Published var timerDuration: Int = 60
    @Published var timeRemaining: Int = 60
    @Published var currentWord: Word? = nil
    @Published var skipEnabled: Bool = false
    
    // Manager access - expose GameCoordinator's managers for UI binding
    var timerManager: TimerManager { gameCoordinator.timerManager }
    var scoreManager: ScoreManager { gameCoordinator.scoreManager }
    var roundManager: RoundManager { gameCoordinator.roundManager }
    var wordManager: WordManager { 
        get { gameCoordinator.wordManager }
        set { gameCoordinator.wordManager = newValue }
    }
    var analyticsManager: AnalyticsManager { gameCoordinator.analyticsManager }
    
    init() {
        // Subscribe to GameCoordinator's phase changes
        gameCoordinator.$currentPhase
            .assign(to: &$currentPhase)
        
        // Subscribe to WordManager's word count changes
        gameCoordinator.wordManager.$words
            .map { $0.count }
            .assign(to: &$wordCount)
        
        // Subscribe to word count changes to update canStartGame
        $wordCount
            .map { $0 >= 3 }
            .assign(to: &$canStartGame)
        
        // Subscribe to TimerManager's timer duration changes
        gameCoordinator.timerManager.$timerDuration
            .assign(to: &$timerDuration)
        
        // Subscribe to TimerManager's time remaining changes
        gameCoordinator.timerManager.$timeRemaining
            .assign(to: &$timeRemaining)
        
        // Subscribe to WordManager's current word changes
        gameCoordinator.wordManager.$currentWord
            .assign(to: &$currentWord)
        
        // Subscribe to WordManager's skip enabled changes
        gameCoordinator.wordManager.$skipEnabled
            .assign(to: &$skipEnabled)
    }
    
    // MARK: - Phase Management (delegated to GameCoordinator)
    func proceedToWordInput() {
        gameCoordinator.proceedToWordInput()
    }
    
    func goToSetupView() {
        gameCoordinator.goToSetupView()
    }
    
    // MARK: - Word Management (delegated to GameCoordinator)
    func addWord(_ wordText: String) {
        gameCoordinator.addWord(wordText)
    }
    
    // Deprecated: Use @Published canStartGame property instead
    // func canStartGame() -> Bool { return canStartGame }
    
    // MARK: - Game Flow (delegated to GameCoordinator)
    func startGame() {
        gameCoordinator.startGame()
    }
    
    func beginRound() {
        gameCoordinator.beginRound()
    }
    
    func beginNextTurn() {
        gameCoordinator.beginNextTurn()
    }
    
    // MARK: - Game Actions (delegated to GameCoordinator)
    func advanceTeamOrRound(wordsExhausted: Bool = false) {
        gameCoordinator.advanceTeamOrRound(wordsExhausted: wordsExhausted)
    }
    
    func wordGuessed() {
        gameCoordinator.wordGuessed()
    }

    func skipCurrentWord() {
        gameCoordinator.skipCurrentWord()
    }
    
    // MARK: - Utility Methods (delegated to GameCoordinator)
    func resetGame() {
        gameCoordinator.resetGame()
    }
    
    func getWinner() -> Int? {
        return gameCoordinator.getWinner()
    }
    
    // MARK: - Analytics Wrapper Methods (delegated to GameCoordinator)
    struct WordStat {
        let word: Word
        let skips: Int
        let averageTime: Double
        let totalTime: Int
    }
    
    func getWordStatistics() -> [WordStat] {
        return gameCoordinator.getWordStatistics()
    }
    
    struct WordsPerMinuteData {
        let round: RoundType
        let team1WPM: Double?
        let team2WPM: Double?
    }
    
    func getWordsPerMinuteData() -> [WordsPerMinuteData] {
        return gameCoordinator.getWordsPerMinuteData()
    }
    
    func getOverallWordsPerMinute() -> (team1WPM: Double?, team2WPM: Double?) {
        return gameCoordinator.getOverallWordsPerMinute()
    }
} 
