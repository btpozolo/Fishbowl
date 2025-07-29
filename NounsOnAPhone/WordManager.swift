import Foundation

// MARK: - Word Manager Protocol
protocol WordManagerProtocol: ObservableObject {
    var words: [Word] { get }
    var currentWord: Word? { get }
    var skipEnabled: Bool { get }
    
    func addWord(_ text: String)
    func getNextWord() -> Word?
    func skipCurrentWord()
    func canStartGame() -> Bool
    func resetWords()
    func markCurrentWordGuessed()
    func hasUnusedWords() -> Bool
}

// MARK: - Word Manager Delegate
protocol WordManagerDelegate: AnyObject {
    func wordManager(_ manager: WordManager, didSkipWord wordId: UUID)
    func wordManager(_ manager: WordManager, didSpendTime timeSpent: Int, onWord wordId: UUID)
}

// MARK: - Word Manager Implementation
class WordManager: ObservableObject, WordManagerProtocol {
    @Published var words: [Word] = []
    @Published var currentWord: Word? = nil
    @Published var skipEnabled: Bool = false
    
    private var unusedWords: [Word] = []
    private var wordStartTime: Date?
    
    // Delegate for word events
    weak var delegate: WordManagerDelegate?
    
    func addWord(_ text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        let newWord = Word(text: trimmedText)
        words.append(newWord)
    }
    
    func canStartGame() -> Bool {
        return words.count >= 3
    }
    
    func setupForRound(usedWordIds: Set<UUID>) {
        if usedWordIds.isEmpty {
            // New round - all words are available
            unusedWords = words
        } else {
            // Same round, different team - only unused words from this round
            unusedWords = words.filter { word in
                !usedWordIds.contains(word.id)
            }
        }
        updateSkipEnabled()
    }
    
    func getNextWord() -> Word? {
        guard !unusedWords.isEmpty else { 
            currentWord = nil
            return nil 
        }
        
        if let randomIndex = unusedWords.indices.randomElement() {
            currentWord = unusedWords[randomIndex]
            wordStartTime = Date()
            updateSkipEnabled()
            return currentWord
        } else {
            currentWord = nil
            return nil
        }
    }
    
    func skipCurrentWord() {
        guard let current = currentWord, unusedWords.count > 1 else { return }
        
        // Record time spent before skipping
        if let startTime = wordStartTime {
            let timeSpent = Int(Date().timeIntervalSince(startTime))
            delegate?.wordManager(self, didSpendTime: max(timeSpent, 1), onWord: current.id)
        }
        
        // Move word to end and increment skip count
        if let index = unusedWords.firstIndex(where: { $0.id == current.id }) {
            let skippedWord = unusedWords.remove(at: index)
            unusedWords.append(skippedWord)
            delegate?.wordManager(self, didSkipWord: skippedWord.id)
            
            // Get next word
            _ = getNextWord()
        }
    }
    
    func markCurrentWordGuessed() {
        guard let current = currentWord else { return }
        
        // Record time spent
        if let startTime = wordStartTime {
            let timeSpent = Int(Date().timeIntervalSince(startTime))
            delegate?.wordManager(self, didSpendTime: max(timeSpent, 1), onWord: current.id)
        }
        
        // Mark word as used and remove from unused pool
        if let index = words.firstIndex(where: { $0.id == current.id }) {
            words[index].used = true
        }
        if let index = unusedWords.firstIndex(where: { $0.id == current.id }) {
            unusedWords.remove(at: index)
        }
        
        updateSkipEnabled()
        wordStartTime = Date() // Reset for next word
    }
    
    func resetWords() {
        words.removeAll()
        unusedWords.removeAll()
        currentWord = nil
        skipEnabled = false
        wordStartTime = nil
    }
    
    private func updateSkipEnabled() {
        skipEnabled = unusedWords.count > 1
    }
    
    func hasUnusedWords() -> Bool {
        return !unusedWords.isEmpty
    }
    
    // MARK: - Convenience Methods
    
    func getUnusedWordCount() -> Int {
        return unusedWords.count
    }
    
    func getTotalWordCount() -> Int {
        return words.count
    }
    
    func getUsedWordCount() -> Int {
        return words.filter { $0.used }.count
    }
    
    func getWordById(_ id: UUID) -> Word? {
        return words.first { $0.id == id }
    }
    
    func isWordUsed(_ wordId: UUID) -> Bool {
        return words.first { $0.id == wordId }?.used ?? false
    }
    
    func getWordProgress() -> (used: Int, total: Int) {
        let usedCount = words.filter { $0.used }.count
        return (used: usedCount, total: words.count)
    }
    
    func getAllWordTexts() -> [String] {
        return words.map { $0.text }
    }
    
    func getUnusedWordTexts() -> [String] {
        return unusedWords.map { $0.text }
    }
    
    func getCurrentWordStartTime() -> Date? {
        return wordStartTime
    }
    
    func resetWordTimestamp() {
        wordStartTime = Date()
    }
    
    // MARK: - Word Validation
    
    func isDuplicateWord(_ text: String) -> Bool {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return words.contains { $0.text.lowercased() == trimmedText }
    }
    
    func isValidWordLength(_ text: String) -> Bool {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedText.count >= 1 && trimmedText.count <= 50
    }
    
    func validateAndAddWord(_ text: String) -> WordValidationResult {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedText.isEmpty {
            return .empty
        }
        
        if !isValidWordLength(trimmedText) {
            return .tooLong
        }
        
        if isDuplicateWord(trimmedText) {
            return .duplicate
        }
        
        addWord(trimmedText)
        return .success
    }
}

// MARK: - Word Validation Result
enum WordValidationResult {
    case success
    case empty
    case tooLong
    case duplicate
    
    var errorMessage: String? {
        switch self {
        case .success:
            return nil
        case .empty:
            return "Word cannot be empty"
        case .tooLong:
            return "Word is too long (max 50 characters)"
        case .duplicate:
            return "Word already exists"
        }
    }
} 