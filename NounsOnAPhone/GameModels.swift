import Foundation

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
    @Published var words: [Word] = []
    @Published var currentPhase: GamePhase = .setup
    @Published var currentWord: Word?
    
    // Manager instances
    let timerManager = TimerManager()
    let scoreManager = ScoreManager()
    let roundManager = RoundManager()
    @Published var skipEnabled: Bool = false // Whether skip button is enabled
    @Published var skipsByWord: [UUID: Int] = [:] // Track skips per word by ID
    @Published var timeSpentByWord: [UUID: Int] = [:] // Track time spent on each word by ID
    
    // New analytics tracking
    @Published var roundStats: [RoundType: (team1Time: Int, team2Time: Int, team1Correct: Int, team2Correct: Int)] = [:]
    @Published var currentRoundStartTime: Date?
    @Published var currentTeamStartTime: Date?
    
    // Track when each team started each round (for accurate WPM calculation)
    private var teamRoundStartTimes: [Int: [RoundType: Date]] = [1: [:], 2: [:]]
    
    // Track each team's cumulative scores by turn
    // Remove team1Scores and team2Scores
    // Add this flag to prevent double-counting turn time
    private var turnTimeAlreadyAdded: Bool = false
    private var unusedWords: [Word] = []
    private var wordStartTime: Date? // Track when current word was displayed
    private let soundManager = SoundManager.shared
    
    init() {
        timerManager.delegate = self
    }
    
    // MARK: - Setup Phase
    func proceedToWordInput() {
        currentPhase = .wordInput
    }
    
    func goToSetupView() {
        currentPhase = .setupView
    }
    
    // MARK: - Word Input Phase
    func addWord(_ wordText: String) {
        let trimmedText = wordText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        let newWord = Word(text: trimmedText)
        words.append(newWord)
    }
    
    func canStartGame() -> Bool {
        return words.count >= 3 // min words to start game
    }
    
    // MARK: - Game Flow
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
    
    // Internal: sets up the next word and starts the timer
    private func startNextTurn() {
        // Only select a word if there are any left
        if !unusedWords.isEmpty {
            getNextWord()
        } else {
            self.currentWord = nil
        }
        timerManager.startTimer()
    }
    
    private func setupRound() {
        // For new rounds, reset the unused words to include all words
        // For team switches within the same round, only include words not used in this round
        let usedWordIds = roundManager.getAllUsedWordIds()
        
        if usedWordIds.isEmpty {
            // New round - all words are available
            unusedWords = words
            // Initialize round stats for new round
            roundStats[roundManager.currentRound] = (team1Time: 0, team2Time: 0, team1Correct: 0, team2Correct: 0)
            currentRoundStartTime = Date()
        } else {
            // Same round, different team - only unused words from this round
            unusedWords = words.filter { word in
                !usedWordIds.contains(word.id)
            }
        }
        // Set currentTeamStartTime at the start of each turn
        currentTeamStartTime = Date()
        
        // Track when this team started this round (for accurate WPM calculation)
        if teamRoundStartTimes[roundManager.currentTeam]?[roundManager.currentRound] == nil {
            teamRoundStartTimes[roundManager.currentTeam]?[roundManager.currentRound] = Date()
        }
        
        // Reset the flag at the start of each turn
        turnTimeAlreadyAdded = false
    }
    
    private func getNextWord() {
        if let randomIndex = unusedWords.indices.randomElement() {
            self.currentWord = unusedWords[randomIndex]
            self.wordStartTime = Date() // Start timing when word is displayed
        } else {
            self.currentWord = nil
            self.wordStartTime = nil
        }
    }
    
    // MARK: - Timer Management (now delegated to TimerManager)
    // Timer methods removed - now handled by TimerManager
    
    // Timer expiration logic moved to TimerManagerDelegate implementation below
    
    // Call this when the user presses 'Continue' on the transition screen
    func advanceTeamOrRound(wordsExhausted: Bool = false) {
        // Do NOT record score here - scores are only recorded at the true end of a team's turn
        
        if wordsExhausted || roundManager.canAdvanceRound(wordsUsed: roundManager.getAllUsedWordIds().count, totalWords: words.count) {
            // If we're in the last round and words are exhausted, end the game
            if roundManager.isFinalRound() {
                currentPhase = .gameOver
                soundManager.handleGamePhaseChange(to: .gameOver)
                return
            }
            
            // Before advancing to next round, record time for current round
            recordTimeForCurrentRound()
            
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
    
    // MARK: - Game Actions
    func wordGuessed() {
        guard let currentWord = currentWord else { return }
        
        // Record time spent on this word
        if let startTime = wordStartTime {
            let timeSpent = Int(Date().timeIntervalSince(startTime))
            // Ensure minimum 1 second is recorded for any word that was displayed
            let adjustedTimeSpent = max(timeSpent, 1)
            timeSpentByWord[currentWord.id, default: 0] += adjustedTimeSpent
        }
        
        // Only increment correct count for the team (do NOT add to teamXTime here)
        if roundManager.currentTeam == 1 {
            roundStats[roundManager.currentRound]?.team1Correct += 1
        } else {
            roundStats[roundManager.currentRound]?.team2Correct += 1
        }
        
        // Increment current team's score
        scoreManager.incrementScore(for: roundManager.currentTeam)
        
        // Reset team start time for next word (but do NOT update currentTeamStartTime here)
        wordStartTime = Date()
        
        // Mark word as used in this round by its unique ID
        roundManager.markWordUsedInRound(currentWord.id)
        // Mark word as used overall
        if let index = words.firstIndex(where: { $0.id == currentWord.id }) {
            words[index].used = true
        }
        // Remove the word from the pool ONLY when guessed
        if let index = unusedWords.firstIndex(where: { $0.id == currentWord.id }) {
            unusedWords.remove(at: index)
        }
        // If there are no more words, end the round or game
        if unusedWords.isEmpty {
            timerManager.stopTimer()
            
            // At the END of the team's turn (round ends), record time for current round
            recordTimeForCurrentRound()
            // Only record score if this is the very end of the game
            if roundManager.isFinalRound() {
                recordTeamTurnScore()
            }
            
            if roundManager.isFinalRound() {
                // Record final score history when game ends
                // Remove buildScoreHistory and all references to team1Scores/team2Scores
                currentPhase = .gameOver
                soundManager.handleGamePhaseChange(to: .gameOver)
            } else {
                currentPhase = .roundTransition
                soundManager.handleGamePhaseChange(to: .roundTransition)
            }
            // Do not switch teams, do not reset timer
            self.currentWord = nil
            roundManager.lastTransitionReason = .wordsExhausted
        } else {
            getNextWord()
        }
    }

    // MARK: - Skip Logic
    func skipCurrentWord() {
        guard let currentWord = currentWord else { return }
        // Only allow skip if more than one word remains
        if unusedWords.count > 1 {
            // Record time spent on this word before skipping
            if let startTime = wordStartTime {
                let timeSpent = Int(Date().timeIntervalSince(startTime))
                // Ensure minimum 1 second is recorded for any word that was displayed
                let adjustedTimeSpent = max(timeSpent, 1)
                timeSpentByWord[currentWord.id, default: 0] += adjustedTimeSpent
            }
            
            // Remove current word from its position
            if let index = unusedWords.firstIndex(where: { $0.id == currentWord.id }) {
                let skippedWord = unusedWords.remove(at: index)
                // Add to end of unusedWords
                unusedWords.append(skippedWord)
                // Increment skip count for this word
                skipsByWord[skippedWord.id, default: 0] += 1
                // Show next word
                getNextWord()
            }
        } else {
            // Only one word left, do not skip
            // TODO: Provide feedback to user (e.g., shake animation)
        }
    }
    
    private func endRound() {
        timerManager.stopTimer()
        currentPhase = .roundTransition
        self.currentWord = nil
    }
    
    // MARK: - Utility
    private func resetScores() {
        scoreManager.resetScores()
        roundManager.resetToFirstRound()
        timerManager.resetTimer()
        roundStats.removeAll()
        currentRoundStartTime = nil
        currentTeamStartTime = nil
        teamRoundStartTimes = [1: [:], 2: [:]]
    }
    
    func resetGame() {
        words.removeAll()
        currentPhase = .setup
        resetScores()
        timerManager.stopTimer()
        self.currentWord = nil
        unusedWords.removeAll()
        skipsByWord.removeAll()
        timeSpentByWord.removeAll()
        soundManager.handleGamePhaseChange(to: .setup)
    }
    
    func getWinner() -> Int? {
        return scoreManager.getWinner()
    }
    
    // MARK: - Word Statistics
    struct WordStat {
        let word: Word
        let skips: Int
        let averageTime: Double
        let totalTime: Int
    }
    
    func getWordStatistics() -> [WordStat] {
        var stats: [WordStat] = []
        
        for word in words {
            let skips = skipsByWord[word.id] ?? 0
            let totalTime = timeSpentByWord[word.id] ?? 0
            
            // Only include words that were actually played (have time spent or skips)
            // This filters out words that were never displayed during the game
            if totalTime > 0 || skips > 0 {
                // Calculate average time: total time divided by 3 (since each word appears in 3 rounds)
                let averageTime = Double(totalTime) / 3.0
                
                stats.append(WordStat(
                    word: word,
                    skips: skips,
                    averageTime: averageTime,
                    totalTime: totalTime
                ))
            }
        }
        
        // Sort by average time descending (slowest words first)
        return stats.sorted { $0.averageTime > $1.averageTime }
    }
    
    // MARK: - Analytics Helper Methods
    
    // Record time spent by current team in current round
    private func recordTimeForCurrentRound() {
        guard !turnTimeAlreadyAdded else { return }
        
        if let roundStartTime = teamRoundStartTimes[roundManager.currentTeam]?[roundManager.currentRound] {
            let timeSpentInRound = Int(Date().timeIntervalSince(roundStartTime))
            
            if roundManager.currentTeam == 1 {
                roundStats[roundManager.currentRound]?.team1Time += timeSpentInRound
            } else {
                roundStats[roundManager.currentRound]?.team2Time += timeSpentInRound
            }
            
            // Reset the round start time for this team/round since we recorded the time
            teamRoundStartTimes[roundManager.currentTeam]?[roundManager.currentRound] = Date()
            turnTimeAlreadyAdded = true
        }
    }
    
    // When a team's turn ends, append their new cumulative score
    private func recordTeamTurnScore() {
        scoreManager.recordCurrentTeamTurnScore(currentTeam: roundManager.currentTeam)
    }
    
    // Remove buildScoreHistory and all references to team1Scores/team2Scores
    
    struct WordsPerMinuteData {
        let round: RoundType
        let team1WPM: Double?
        let team2WPM: Double?
    }
    
    func getWordsPerMinuteData() -> [WordsPerMinuteData] {
        var wpmData: [WordsPerMinuteData] = []
        
        for round in RoundType.allCases {
            if let stats = roundStats[round] {
                let team1WPM: Double? = stats.team1Time > 0 ? Double(stats.team1Correct) / (Double(stats.team1Time) / 60.0) : nil
                let team2WPM: Double? = stats.team2Time > 0 ? Double(stats.team2Correct) / (Double(stats.team2Time) / 60.0) : nil
                
                wpmData.append(WordsPerMinuteData(
                    round: round,
                    team1WPM: team1WPM,
                    team2WPM: team2WPM
                ))
            }
        }
        
        return wpmData
    }
    
    func getOverallWordsPerMinute() -> (team1WPM: Double?, team2WPM: Double?) {
        var team1TotalTime = 0
        var team2TotalTime = 0
        var team1TotalCorrect = 0
        var team2TotalCorrect = 0
        
        for (_, stats) in roundStats {
            team1TotalTime += stats.team1Time
            team2TotalTime += stats.team2Time
            team1TotalCorrect += stats.team1Correct
            team2TotalCorrect += stats.team2Correct
        }
        
        let team1WPM: Double? = team1TotalTime > 0 ? Double(team1TotalCorrect) / (Double(team1TotalTime) / 60.0) : nil
        let team2WPM: Double? = team2TotalTime > 0 ? Double(team2TotalCorrect) / (Double(team2TotalTime) / 60.0) : nil
        
        return (team1WPM: team1WPM, team2WPM: team2WPM)
    }
}

// MARK: - TimerManagerDelegate
extension GameState: TimerManagerDelegate {
    func timerDidExpire() {
        // Record time spent on current word if timer expires
        if let currentWord = currentWord, let startTime = wordStartTime {
            let timeSpent = Int(Date().timeIntervalSince(startTime))
            // Ensure minimum 1 second is recorded for any word that was displayed
            let adjustedTimeSpent = max(timeSpent, 1)
            timeSpentByWord[currentWord.id, default: 0] += adjustedTimeSpent
        }
        
        // At the END of the team's turn (timer expired), record time for current round
        recordTimeForCurrentRound()
        // Record score at the end of the team turn (timer expired)
        recordTeamTurnScore()
        
        // If there are still words left, switch teams and continue the round
        if !unusedWords.isEmpty {
            roundManager.switchTeam()
            timerManager.resetTimer()
            currentPhase = .roundTransition
            self.currentWord = nil
            soundManager.handleGamePhaseChange(to: .roundTransition)
        } else {
            // If no words left, move to next round or end game
            roundManager.lastTransitionReason = .wordsExhausted
            advanceTeamOrRound(wordsExhausted: true)
        }
    }
} 
