import Testing
@testable import NounsOnAPhone
import Foundation

struct WordManagerTests {
    
    // MARK: - Basic Word Management Tests
    
    @Test func wordManagerInitialState() async throws {
        let wordManager = WordManager()
        
        #expect(wordManager.words.isEmpty)
        #expect(wordManager.currentWord == nil)
        #expect(wordManager.skipEnabled == false)
    }
    
    @Test func addWordValidation() async throws {
        let wordManager = WordManager()
        
        // Test valid word addition
        let result1 = wordManager.validateAndAddWord("pizza")
        #expect(result1 == .success)
        #expect(wordManager.words.count == 1)
        #expect(wordManager.words.first?.text == "pizza")
        
        // Test duplicate word rejection
        let result2 = wordManager.validateAndAddWord("pizza")
        #expect(result2 == .duplicate)
        #expect(wordManager.words.count == 1)
        
        // Test empty word rejection
        let result3 = wordManager.validateAndAddWord("")
        #expect(result3 == .empty)
        #expect(wordManager.words.count == 1)
        
        // Test whitespace-only word rejection
        let result4 = wordManager.validateAndAddWord("   ")
        #expect(result4 == .empty)
        #expect(wordManager.words.count == 1)
    }
    
    @Test func addWordCaseInsensitiveDuplicates() async throws {
        let wordManager = WordManager()
        
        #expect(wordManager.validateAndAddWord("Pizza") == .success)
        #expect(wordManager.validateAndAddWord("PIZZA") == .duplicate)
        #expect(wordManager.validateAndAddWord("pizza") == .duplicate)
        #expect(wordManager.words.count == 1)
    }
    
    @Test func addWordLengthLimits() async throws {
        let wordManager = WordManager()
        
        // Test very long word (assuming 50 character limit)
        let longWord = String(repeating: "a", count: 51)
        let result = wordManager.validateAndAddWord(longWord)
        #expect(result == .tooLong)
        #expect(wordManager.words.isEmpty)
        
        // Test acceptable length word
        let normalWord = "reasonable"
        #expect(wordManager.validateAndAddWord(normalWord) == .success)
        #expect(wordManager.words.count == 1)
    }
    
    // MARK: - Word Selection Tests
    
    @Test func getNextWordFromEmptyList() async throws {
        let wordManager = WordManager()
        
        let nextWord = wordManager.getNextWord()
        #expect(nextWord == nil)
    }
    
    @Test func getNextWordSingleWord() async throws {
        let wordManager = WordManager()
        
        wordManager.addWord("pizza")
        wordManager.setupForRound(usedWordIds: [])
        let nextWord = wordManager.getNextWord()
        
        #expect(nextWord != nil)
        #expect(nextWord?.text == "pizza")
        #expect(wordManager.currentWord?.text == "pizza")
    }
    
    @Test func getNextWordMultipleWords() async throws {
        let wordManager = WordManager()
        
        wordManager.addWord("pizza")
        wordManager.addWord("burger")
        wordManager.addWord("taco")
        wordManager.setupForRound(usedWordIds: [])
        
        let firstWord = wordManager.getNextWord()
        #expect(firstWord != nil)
        
        // Should select from available words
        let selectedWords = Set([firstWord?.text])
        let secondWord = wordManager.getNextWord()
        #expect(secondWord != nil)
        #expect(!selectedWords.contains(secondWord?.text))
    }
    
    @Test func getNextWordAfterAllUsed() async throws {
        let wordManager = WordManager()
        
        wordManager.addWord("pizza")
        wordManager.setupForRound(usedWordIds: [])
        
        // Use the only word
        _ = wordManager.getNextWord()
        wordManager.markCurrentWordGuessed()
        
        // Should return nil when no unused words
        let nextWord = wordManager.getNextWord()
        #expect(nextWord == nil)
        #expect(!wordManager.hasUnusedWords())
    }
    
    // MARK: - Skip Functionality Tests
    
    @Test func skipEnabledAfterEnoughWords() async throws {
        let wordManager = WordManager()
        
        // Skip should be disabled with few words
        wordManager.addWord("pizza")
        wordManager.addWord("burger")
        wordManager.setupForRound(usedWordIds: [])
        #expect(wordManager.skipEnabled == false)
        
        // Skip should be enabled with enough words
        wordManager.addWord("taco")
        wordManager.addWord("pasta")
        wordManager.setupForRound(usedWordIds: [])
        #expect(wordManager.skipEnabled == true)
    }
    
    @Test func skipCurrentWord() async throws {
        let wordManager = WordManager()
        let delegate = MockWordManagerDelegate()
        wordManager.delegate = delegate
        
        wordManager.addWord("pizza")
        wordManager.addWord("burger")
        wordManager.addWord("taco")
        wordManager.addWord("pasta")
        wordManager.setupForRound(usedWordIds: [])
        
        let firstWord = wordManager.getNextWord()
        #expect(firstWord != nil)
        
        // Skip the current word
        wordManager.skipCurrentWord()
        
        // Verify delegate was called
        #expect(delegate.skippedWords.count == 1)
        #expect(delegate.skippedWords.first == firstWord?.id)
        
        // Verify current word changed
        #expect(wordManager.currentWord?.id != firstWord?.id)
    }
    
    @Test func skipWithoutCurrentWord() async throws {
        let wordManager = WordManager()
        let delegate = MockWordManagerDelegate()
        wordManager.delegate = delegate
        
        // Skip when no current word should not crash
        wordManager.skipCurrentWord()
        #expect(delegate.skippedWords.isEmpty)
    }
    
    @Test func skipLastRemainingWord() async throws {
        let wordManager = WordManager()
        
        wordManager.addWord("pizza")
        wordManager.setupForRound(usedWordIds: [])
        _ = wordManager.getNextWord()
        
        // Should not be able to skip if it's the last word
        wordManager.skipCurrentWord()
        #expect(wordManager.currentWord?.text == "pizza")
    }
    
    // MARK: - Round Setup Tests
    
    @Test func setupForRoundWithUsedWords() async throws {
        let wordManager = WordManager()
        
        wordManager.addWord("pizza")
        wordManager.addWord("burger")
        wordManager.addWord("taco")
        
        let word1 = wordManager.words[0]
        
        // Setup round with some used words
        let usedWordIds: Set<UUID> = [word1.id]
        wordManager.setupForRound(usedWordIds: usedWordIds)
        
        // Should only have unused words available
        #expect(wordManager.hasUnusedWords())
        
        // Should get an unused word
        let nextWord = wordManager.getNextWord()
        #expect(nextWord != nil)
        #expect(nextWord?.id != word1.id)
    }
    
    @Test func setupForRoundWithAllWordsUsed() async throws {
        let wordManager = WordManager()
        
        wordManager.addWord("pizza")
        wordManager.addWord("burger")
        
        let word1 = wordManager.words[0]
        let word2 = wordManager.words[1]
        
        // Setup round with all words used
        let usedWordIds: Set<UUID> = [word1.id, word2.id]
        wordManager.setupForRound(usedWordIds: usedWordIds)
        
        #expect(!wordManager.hasUnusedWords())
        #expect(wordManager.getNextWord() == nil)
    }
    
    // MARK: - Word State Management Tests
    
    @Test func markCurrentWordGuessed() async throws {
        let wordManager = WordManager()
        let delegate = MockWordManagerDelegate()
        wordManager.delegate = delegate
        
        wordManager.addWord("pizza")
        wordManager.setupForRound(usedWordIds: [])
        let word = wordManager.getNextWord()
        #expect(word != nil)
        
        // Mark word as guessed
        wordManager.markCurrentWordGuessed()
        
        // Verify delegate was called with time spent
        #expect(delegate.timeSpentRecords.count == 1)
        #expect(delegate.timeSpentRecords.first?.wordId == word?.id)
        #expect(delegate.timeSpentRecords.first?.timeSpent ?? 0 > 0)
    }
    
    @Test func getTotalWordCount() async throws {
        let wordManager = WordManager()
        
        #expect(wordManager.getTotalWordCount() == 0)
        
        wordManager.addWord("pizza")
        #expect(wordManager.getTotalWordCount() == 1)
        
        wordManager.addWord("burger")
        #expect(wordManager.getTotalWordCount() == 2)
    }
    
    @Test func getWordProgress() async throws {
        let wordManager = WordManager()
        
        wordManager.addWord("pizza")
        wordManager.addWord("burger")
        wordManager.addWord("taco")
        
        // Setup with one used word
        let usedWordIds: Set<UUID> = [wordManager.words[0].id]
        wordManager.setupForRound(usedWordIds: usedWordIds)
        
        let progress = wordManager.getWordProgress()
        #expect(progress.used == 1)
        #expect(progress.total == 3)
    }
    
    // MARK: - Convenience Method Tests
    
    @Test func canStartGame() async throws {
        let wordManager = WordManager()
        
        // Not enough words to start
        #expect(!wordManager.canStartGame())
        
        wordManager.addWord("pizza")
        #expect(!wordManager.canStartGame())
        
        wordManager.addWord("burger")
        #expect(!wordManager.canStartGame())
        
        wordManager.addWord("taco")
        #expect(wordManager.canStartGame())
    }
    
    @Test func resetWords() async throws {
        let wordManager = WordManager()
        
        wordManager.addWord("pizza")
        wordManager.addWord("burger")
        wordManager.setupForRound(usedWordIds: [])
        _ = wordManager.getNextWord()
        
        #expect(wordManager.words.count == 2)
        #expect(wordManager.currentWord != nil)
        
        wordManager.resetWords()
        
        #expect(wordManager.words.isEmpty)
        #expect(wordManager.currentWord == nil)
    }
}

// MARK: - Mock Delegate

class MockWordManagerDelegate: WordManagerDelegate {
    var skippedWords: [UUID] = []
    var timeSpentRecords: [(wordId: UUID, timeSpent: Int)] = []
    
    func wordManager(_ manager: WordManager, didSkipWord wordId: UUID) {
        skippedWords.append(wordId)
    }
    
    func wordManager(_ manager: WordManager, didSpendTime timeSpent: Int, onWord wordId: UUID) {
        timeSpentRecords.append((wordId: wordId, timeSpent: timeSpent))
    }
} 