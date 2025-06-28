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

class GameState: ObservableObject {
    @Published var words: [Word] = []
    @Published var currentPhase: GamePhase = .wordInput
    @Published var currentRound: RoundType = .describe
    @Published var currentWord: Word?
    @Published var timeRemaining: Int = 60
    @Published var timerDuration: Int = 60 // Default 60 seconds
    @Published var team1Score: Int = 0
    @Published var team2Score: Int = 0
    @Published var currentTeam: Int = 1
    @Published var isTimerRunning: Bool = false
    
    private var timer: Timer?
    private var unusedWords: [Word] = []
    private var roundUsedWords: Set<String> = [] // Track used words per round
    
    // MARK: - Word Input Phase
    func addWord(_ wordText: String) {
        let trimmedText = wordText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        let newWord = Word(text: trimmedText)
        words.append(newWord)
    }
    
    func canStartGame() -> Bool {
        return words.count >= 3
    }
    
    // MARK: - Game Flow
    func startGame() {
        currentPhase = .gameOverview
        resetScores()
    }
    
    func beginRound() {
        currentPhase = .playing
        setupRound()
        startTimer()
    }
    
    private func setupRound() {
        // For new rounds, reset the unused words to include all words
        // For team switches within the same round, only include words not used in this round
        if roundUsedWords.isEmpty {
            // New round - all words are available
            unusedWords = words.map { Word(text: $0.text) }
        } else {
            // Same round, different team - only unused words from this round
            unusedWords = words.filter { word in
                !roundUsedWords.contains(word.text)
            }.map { Word(text: $0.text) }
        }
        
        getNextWord()
    }
    
    private func getNextWord() {
        if let randomIndex = unusedWords.indices.randomElement() {
            currentWord = unusedWords[randomIndex]
            unusedWords.remove(at: randomIndex)
        } else {
            // All words used in this round, end round
            endRound()
        }
    }
    
    // MARK: - Timer Management
    private func startTimer() {
        // Don't reset timer if we're carrying over time from previous round
        if timeRemaining == timerDuration {
            timeRemaining = timerDuration
        }
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
        currentPhase = .roundTransition
        
        // Add current word back to the pool for next team in same round
        if let currentWord = currentWord {
            unusedWords.append(currentWord)
        }
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
        
        // Mark word as used in this round
        roundUsedWords.insert(currentWord.text)
        
        // Mark word as used overall
        if let index = words.firstIndex(where: { $0.text == currentWord.text }) {
            words[index].used = true
        }
        
        // Get next word or end round
        if unusedWords.isEmpty {
            endRound()
        } else {
            getNextWord()
        }
    }
    
    private func endRound() {
        stopTimer()
        
        if currentRound == .oneWord {
            // Game is over
            currentPhase = .gameOver
        } else {
            // Move to round transition - round advancement will be handled in nextTeam()
            currentPhase = .roundTransition
        }
    }
    
    func nextTeam() {
        // If all words have been used in this round, move to next round
        if currentRound != .oneWord && roundUsedWords.count >= words.count {
            // Advance to next round, same team continues, keep remaining time
            switch currentRound {
            case .describe:
                currentRound = .actOut
            case .actOut:
                currentRound = .oneWord
            case .oneWord:
                break // Shouldn't reach here
            }
            roundUsedWords.removeAll()
            // Do NOT switch teams or reset timer
        } else {
            // Still in the same round, switch teams if timer expired
            if timeRemaining == 0 {
                currentTeam = currentTeam == 1 ? 2 : 1
                timeRemaining = timerDuration // Reset timer for new team
            }
            // If timeRemaining > 0, keep the same team and their remaining time
        }

        currentPhase = .playing
        setupRound()
        startTimer()
    }
    
    // MARK: - Utility
    private func resetScores() {
        team1Score = 0
        team2Score = 0
        currentTeam = 1
        currentRound = .describe
        timeRemaining = timerDuration
        roundUsedWords.removeAll()
    }
    
    func resetGame() {
        words.removeAll()
        currentPhase = .wordInput
        resetScores()
        stopTimer()
        currentWord = nil
        unusedWords.removeAll()
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
