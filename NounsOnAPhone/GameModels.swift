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
    @Published var currentRound: RoundType = .describe
    @Published var currentWord: Word?
    @Published var timeRemaining: Int = 60
    @Published var timerDuration: Int = 60 // Default 60 seconds
    @Published var team1Score: Int = 0
    @Published var team2Score: Int = 0
    @Published var currentTeam: Int = 1
    @Published var isTimerRunning: Bool = false
    @Published var lastTransitionReason: TransitionReason? = nil
    
    private var timer: Timer?
    private var unusedWords: [Word] = []
    private var roundUsedWordIds: Set<UUID> = [] // Track used word IDs per round
    private let soundManager = SoundManager.shared
    
    // MARK: - Setup Phase
    func proceedToWordInput() {
        currentPhase = .wordInput
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
        timeRemaining = timerDuration
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
        startTimer()
    }
    
    private func setupRound() {
        // For new rounds, reset the unused words to include all words
        // For team switches within the same round, only include words not used in this round
        if roundUsedWordIds.isEmpty {
            // New round - all words are available
            unusedWords = words
        } else {
            // Same round, different team - only unused words from this round
            unusedWords = words.filter { word in
                !roundUsedWordIds.contains(word.id)
            }
        }
    }
    
    private func getNextWord() {
        if let randomIndex = unusedWords.indices.randomElement() {
            self.currentWord = unusedWords[randomIndex]
        } else {
            self.currentWord = nil
        }
    }
    
    // MARK: - Timer Management
    private func startTimer() {
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
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }
    
    private func timerExpired() {
        stopTimer()
        soundManager.handleTimerExpired()
        // If there are still words left, switch teams and continue the round
        if !unusedWords.isEmpty {
            currentTeam = currentTeam == 1 ? 2 : 1
            timeRemaining = timerDuration
            currentPhase = .roundTransition
            self.currentWord = nil
            lastTransitionReason = .timerExpired
            soundManager.handleGamePhaseChange(to: .roundTransition)
        } else {
            // If no words left, move to next round or end game
            lastTransitionReason = .wordsExhausted
            advanceTeamOrRound(wordsExhausted: true)
        }
    }
    
    // Call this when the user presses 'Continue' on the transition screen
    func advanceTeamOrRound(wordsExhausted: Bool = false) {
        if wordsExhausted || (currentRound != .oneWord && roundUsedWordIds.count >= words.count) {
            // If we're in the last round and words are exhausted, end the game
            if currentRound == .oneWord {
                currentPhase = .gameOver
                soundManager.handleGamePhaseChange(to: .gameOver)
                return
            }
            // Advance to next round, same team continues, keep remaining time
            switch currentRound {
            case .describe:
                currentRound = .actOut
            case .actOut:
                currentRound = .oneWord
            case .oneWord:
                break // Shouldn't reach here
            }
            roundUsedWordIds.removeAll()
            setupRound()
            // Do NOT reset timer or switch teams
        } else if timeRemaining == timerDuration {
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
        // Increment current team's score
        if currentTeam == 1 {
            team1Score += 1
        } else {
            team2Score += 1
        }
        // Mark word as used in this round by its unique ID
        roundUsedWordIds.insert(currentWord.id)
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
            stopTimer()
            if currentRound == .oneWord {
                currentPhase = .gameOver
                soundManager.handleGamePhaseChange(to: .gameOver)
            } else {
                currentPhase = .roundTransition
                soundManager.handleGamePhaseChange(to: .roundTransition)
            }
            // Do not switch teams, do not reset timer
            self.currentWord = nil
            lastTransitionReason = .wordsExhausted
        } else {
            getNextWord()
        }
    }
    
    private func endRound() {
        stopTimer()
        currentPhase = .roundTransition
        self.currentWord = nil
    }
    
    // MARK: - Utility
    private func resetScores() {
        team1Score = 0
        team2Score = 0
        currentTeam = 1
        currentRound = .describe
        timeRemaining = timerDuration
        roundUsedWordIds.removeAll()
    }
    
    func resetGame() {
        words.removeAll()
        currentPhase = .setup
        resetScores()
        stopTimer()
        self.currentWord = nil
        unusedWords.removeAll()
        soundManager.handleGamePhaseChange(to: .setup)
    }
    
    func getWinner() -> Int? {
        if team1Score > team2Score {
            return 1
        } else if team2Score > team1Score {
            return 2
        } else {
            return nil // Tie
        }
    }
} 
