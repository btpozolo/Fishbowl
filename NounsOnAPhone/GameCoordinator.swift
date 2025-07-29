import Foundation

// MARK: - Game Coordinator Protocol
protocol GameCoordinatorProtocol: ObservableObject {
    // Published properties for UI binding
    var currentPhase: GamePhase { get }
    
    // Manager access
    var timerManager: TimerManager { get }
    var scoreManager: ScoreManager { get }
    var roundManager: RoundManager { get }
    var wordManager: WordManager { get }
    var analyticsManager: AnalyticsManager { get }
    
    // Phase management
    func proceedToWordInput()
    func goToSetupView()
    func startGame()
    func beginRound()
    func beginNextTurn()
    
    // Game actions
    func wordGuessed()
    func skipCurrentWord()
    func advanceTeamOrRound(wordsExhausted: Bool)
    
    // Word management
    func addWord(_ wordText: String)
    func canStartGame() -> Bool
    
    // Utility methods
    func resetGame()
    func getWinner() -> Int?
    func getWordStatistics() -> [GameState.WordStat]
    func getWordsPerMinuteData() -> [GameState.WordsPerMinuteData]
    func getOverallWordsPerMinute() -> (team1WPM: Double?, team2WPM: Double?)
}

// MARK: - Game Coordinator Implementation
class GameCoordinator: ObservableObject, GameCoordinatorProtocol {
    @Published var currentPhase: GamePhase = .setup
    
    // Manager instances
    let timerManager = TimerManager()
    let scoreManager = ScoreManager()
    let roundManager = RoundManager()
    var wordManager = WordManager()
    let analyticsManager = AnalyticsManager()
    
    private let soundManager = SoundManager.shared
    
    init() {
        setupDelegates()
    }
    
    private func setupDelegates() {
        timerManager.delegate = self
        wordManager.delegate = self
    }
    
    // MARK: - Phase Management
    func proceedToWordInput() {
        currentPhase = .wordInput
    }
    
    func goToSetupView() {
        currentPhase = .setupView
    }
    
    func startGame() {
        currentPhase = .gameOverview
        resetScores()
    }
    
    func beginRound() {
        currentPhase = .playing
        // Reset timer to full duration when starting the first round
        timerManager.resetTimer()
        setupRound()
        startNextTurn()
        soundManager.handleGamePhaseChange(to: .playing)
    }
    
    // Call this from the transition screen's Continue button
    func beginNextTurn() {
        currentPhase = .playing
        startNextTurn()
        soundManager.handleGamePhaseChange(to: .playing)
    }
    
    // MARK: - Word Management
    func addWord(_ wordText: String) {
        wordManager.addWord(wordText)
    }
    
    func canStartGame() -> Bool {
        return wordManager.canStartGame()
    }
    
    // MARK: - Game Actions
    func wordGuessed() {
        guard let currentWord = wordManager.currentWord else { return }
        
        // Record correct guess in analytics
        analyticsManager.recordCorrectGuess(for: roundManager.currentTeam, in: roundManager.currentRound)
        
        // Increment current team's score
        scoreManager.incrementScore(for: roundManager.currentTeam)
        
        // Mark word as used in this round by its unique ID
        roundManager.markWordUsedInRound(currentWord.id)
        
        // Let word manager handle word guessing logic (time tracking, marking as used, removing from pool)
        wordManager.markCurrentWordGuessed()
        
        // If there are no more words, end the round or game
        if !wordManager.hasUnusedWords() {
            timerManager.stopTimer()
            
            // At the END of the team's turn (round ends), record time for current round
            analyticsManager.recordTimeForCurrentRound(team: roundManager.currentTeam, round: roundManager.currentRound)
            // Only record score if this is the very end of the game
            if roundManager.isFinalRound() {
                recordTeamTurnScore()
            }
            
            if roundManager.isFinalRound() {
                // Record final score history when game ends
                currentPhase = .gameOver
                soundManager.handleGamePhaseChange(to: .gameOver)
            } else {
                currentPhase = .roundTransition
                soundManager.handleGamePhaseChange(to: .roundTransition)
            }
            roundManager.lastTransitionReason = .wordsExhausted
        } else {
            _ = wordManager.getNextWord()
        }
    }
    
    func skipCurrentWord() {
        wordManager.skipCurrentWord()
    }
    
    // Call this when the user presses 'Continue' on the transition screen
    func advanceTeamOrRound(wordsExhausted: Bool = false) {
        // Do NOT record score here - scores are only recorded at the true end of a team's turn
        
        if wordsExhausted || roundManager.canAdvanceRound(wordsUsed: roundManager.getAllUsedWordIds().count, totalWords: wordManager.words.count) {
            // If we're in the last round and words are exhausted, end the game
            if roundManager.isFinalRound() {
                currentPhase = .gameOver
                soundManager.handleGamePhaseChange(to: .gameOver)
                return
            }
            
            // Before advancing to next round, record time for current round
            analyticsManager.recordTimeForCurrentRound(team: roundManager.currentTeam, round: roundManager.currentRound)
            
            // Advance to next round, same team continues, keep remaining time
            roundManager.advanceRound()
            setupRound()
            // Do NOT reset timer or switch teams
        } else if timerManager.timeRemaining == timerManager.timerDuration {
            // This means timer expired and we switched teams
            // Already handled in timerExpired
            setupRound()
        }
        // When user presses Continue, actually start the next turn
        beginNextTurn()
    }
    
    // MARK: - Utility Methods
    func resetGame() {
        wordManager.resetWords()
        currentPhase = .setup
        resetScores()
        timerManager.stopTimer()
        analyticsManager.resetAnalytics()
        soundManager.handleGamePhaseChange(to: .setup)
    }
    
    func getWinner() -> Int? {
        return scoreManager.getWinner()
    }
    
    // MARK: - Analytics Wrapper Methods
    func getWordStatistics() -> [GameState.WordStat] {
        return analyticsManager.getWordStatistics(from: wordManager.words)
    }
    
    func getWordsPerMinuteData() -> [GameState.WordsPerMinuteData] {
        return analyticsManager.getWordsPerMinuteData()
    }
    
    func getOverallWordsPerMinute() -> (team1WPM: Double?, team2WPM: Double?) {
        return analyticsManager.getOverallWordsPerMinute()
    }
    
    // MARK: - Private Helper Methods
    
    // Internal: sets up the next word and starts the timer
    private func startNextTurn() {
        // Only select a word if there are any left
        if wordManager.hasUnusedWords() {
            _ = wordManager.getNextWord()
        }
        timerManager.startTimer()
    }
    
    private func setupRound() {
        // Set up word manager for round
        let usedWordIds = roundManager.getAllUsedWordIds()
        wordManager.setupForRound(usedWordIds: usedWordIds)
        
        if usedWordIds.isEmpty {
            // Initialize round stats for new round
            analyticsManager.initializeRoundStats(for: roundManager.currentRound)
        }
        
        // Track when this team started this round (for accurate WPM calculation)
        analyticsManager.recordRoundStartTime(for: roundManager.currentTeam, round: roundManager.currentRound)
    }
    
    private func resetScores() {
        scoreManager.resetScores()
        roundManager.resetToFirstRound()
        timerManager.resetTimer()
        analyticsManager.resetAnalytics()
    }
    
    private func endRound() {
        timerManager.stopTimer()
        currentPhase = .roundTransition
    }
    
    // When a team's turn ends, append their new cumulative score
    private func recordTeamTurnScore() {
        scoreManager.recordCurrentTeamTurnScore(currentTeam: roundManager.currentTeam)
    }
}

// MARK: - Manager Delegates
extension GameCoordinator: TimerManagerDelegate {
    func timerDidExpire() {
        // Record time spent on current word if timer expires (handled by WordManager delegate)
        
        // At the END of the team's turn (timer expired), record time for current round
        analyticsManager.recordTimeForCurrentRound(team: roundManager.currentTeam, round: roundManager.currentRound)
        // Record score at the end of the team turn (timer expired)
        recordTeamTurnScore()
        
        // If there are still words left, switch teams and continue the round
        if wordManager.hasUnusedWords() {
            roundManager.switchTeam()
            timerManager.resetTimer()
            currentPhase = .roundTransition
            roundManager.lastTransitionReason = .timerExpired
            soundManager.handleGamePhaseChange(to: .roundTransition)
        } else {
            // If no words left, move to next round or end game
            roundManager.lastTransitionReason = .wordsExhausted
            advanceTeamOrRound(wordsExhausted: true)
        }
    }
}

extension GameCoordinator: WordManagerDelegate {
    func wordManager(_ manager: WordManager, didSkipWord wordId: UUID) {
        analyticsManager.recordWordSkip(wordId: wordId)
    }
    
    func wordManager(_ manager: WordManager, didSpendTime timeSpent: Int, onWord wordId: UUID) {
        analyticsManager.recordWordTime(wordId: wordId, timeSpent: timeSpent)
    }
} 