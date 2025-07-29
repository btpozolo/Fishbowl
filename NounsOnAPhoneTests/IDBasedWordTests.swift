import XCTest
@testable import NounsOnAPhone

final class IDBasedWordTests: XCTestCase {
    var gameState: GameState!
    
    override func setUp() {
        super.setUp()
        gameState = GameState()
    }
    
    override func tearDown() {
        gameState = nil
        super.tearDown()
    }
    
    // MARK: - ID-Based Word Tracking Tests
    
    func testUniqueWordIDsAreGenerated() {
        // Test that each word gets a unique ID
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        
        let wordIds = Set(gameState.wordManager.words.map { $0.id })
        XCTAssertEqual(wordIds.count, 3, "Each word should have a unique ID")
        XCTAssertEqual(gameState.wordManager.words.count, 3, "Should have 3 words")
    }
    
    func testWordTrackingByID() {
        // Test that words are tracked by their unique IDs, not text content
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        gameState.addWord("burger")
        
        gameState.startGame()
        gameState.beginRound()
        
        // Track which specific word instances are used
        var usedWordIds: Set<UUID> = []
        var currentWord = gameState.wordManager.currentWord
        
        while currentWord != nil {
            if let word = currentWord {
                // Each word instance should be unique
                XCTAssertFalse(usedWordIds.contains(word.id), "Should not get the same word instance twice")
                usedWordIds.insert(word.id)
                gameState.wordGuessed()
                currentWord = gameState.wordManager.currentWord
            }
        }
        
        // Should have used exactly 3 unique word instances
        XCTAssertEqual(usedWordIds.count, 3, "Should use exactly 3 unique word instances")
    }
    
    func testDuplicateWordsAreTreatedAsSeparate() {
        // Test that duplicate words are treated as separate entities
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        
        gameState.startGame()
        gameState.beginRound()
        
        var pizzaGuessed = 0
        var currentWord = gameState.wordManager.currentWord
        
        while currentWord != nil && pizzaGuessed < 3 {
            if currentWord?.text == "pizza" {
                pizzaGuessed += 1
            }
            gameState.wordGuessed()
            currentWord = gameState.wordManager.currentWord
        }
        
        // Should be able to guess pizza exactly 3 times (once for each instance)
        XCTAssertEqual(pizzaGuessed, 3, "Should guess pizza exactly 3 times")
    }
    
    func testScoreCalculationWithDuplicateWords() {
        // Test that each word instance gives exactly 1 point
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        gameState.addWord("burger")
        
        gameState.startGame()
        gameState.beginRound()
        
        let initialScore = gameState.scoreManager.team1Score
        var wordsGuessed = 0
        
        // Guess all words
        while gameState.wordManager.currentWord != nil {
            gameState.wordGuessed()
            wordsGuessed += 1
        }
        
        let finalScore = gameState.scoreManager.team1Score
        let scoreIncrease = finalScore - initialScore
        
        // Should get 1 point for each word instance
        XCTAssertEqual(scoreIncrease, wordsGuessed, "Score should increase by 1 for each word guessed")
        XCTAssertEqual(scoreIncrease, 4, "Should get exactly 4 points for 4 word instances")
    }
    
    func testRoundTransitionWithDuplicateWords() {
        // Test that round transitions work correctly with duplicate words
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        gameState.addWord("burger")
        
        gameState.startGame()
        gameState.beginRound()
        
        // Guess all words in the first round
        while gameState.wordManager.currentWord != nil {
            gameState.wordGuessed()
        }
        
        // Should transition to next round
        XCTAssertEqual(gameState.currentPhase, .roundTransition, "Should transition to round transition")
        
        // Continue to next round
        gameState.advanceTeamOrRound()
        
        // Should be in playing phase for the next round
        XCTAssertEqual(gameState.currentPhase, .playing, "Should be in playing phase for next round")
        
        // All words should be available again for the new round
        XCTAssertNotNil(gameState.wordManager.currentWord, "Should have a current word in the new round")
    }
    
    func testWordRemovalByID() {
        // Test that words are properly removed by their unique IDs
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        gameState.addWord("burger")
        
        gameState.startGame()
        gameState.beginRound()
        
        var guessedWordIds: Set<UUID> = []
        
        // Guess words and track their IDs
        while gameState.wordManager.currentWord != nil {
            if let currentWord = gameState.wordManager.currentWord {
                guessedWordIds.insert(currentWord.id)
            }
            gameState.wordGuessed()
        }
        
        // Should have guessed exactly 3 unique word instances
        XCTAssertEqual(guessedWordIds.count, 3, "Should guess exactly 3 unique word instances")
        
        // Check that all guessed words are marked as used
        let usedWords = gameState.wordManager.words.filter { $0.used }
        XCTAssertEqual(usedWords.count, 3, "Should have exactly 3 words marked as used")
        
        // Check that the used words match the guessed words
        let usedWordIds = Set(usedWords.map { $0.id })
        XCTAssertEqual(usedWordIds, guessedWordIds, "Used word IDs should match guessed word IDs")
    }
    
    func testCaseSensitivityWithIDs() {
        // Test that different case variations are treated as separate words with unique IDs
        gameState.addWord("Pizza")
        gameState.addWord("pizza")
        gameState.addWord("PIZZA")
        
        let wordIds = Set(gameState.wordManager.words.map { $0.id })
        XCTAssertEqual(wordIds.count, 3, "Each case variation should have a unique ID")
        
        gameState.startGame()
        gameState.beginRound()
        
        var guessedWords: Set<String> = []
        
        // Guess all words
        while gameState.wordManager.currentWord != nil {
            if let currentWord = gameState.wordManager.currentWord {
                guessedWords.insert(currentWord.text)
            }
            gameState.wordGuessed()
        }
        
        // Should have guessed all 3 case variations
        XCTAssertEqual(guessedWords.count, 3, "Should guess all 3 case variations")
        XCTAssertTrue(guessedWords.contains("Pizza"), "Should guess 'Pizza'")
        XCTAssertTrue(guessedWords.contains("pizza"), "Should guess 'pizza'")
        XCTAssertTrue(guessedWords.contains("PIZZA"), "Should guess 'PIZZA'")
    }
    
    func testPerformanceWithManyDuplicateWords() {
        // Test performance with many duplicate words using ID-based tracking
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<100 {
            gameState.addWord("pizza")
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        
        XCTAssertEqual(gameState.wordManager.words.count, 100, "Should add 100 instances of pizza")
        XCTAssertLessThan(duration, 1.0, "Adding 100 duplicate words should take less than 1 second")
        
        // Test that all words have unique IDs
        let wordIds = Set(gameState.wordManager.words.map { $0.id })
        XCTAssertEqual(wordIds.count, 100, "All 100 words should have unique IDs")
    }
    
    func testGameResetWithIDBasedTracking() {
        // Test that game reset works properly with ID-based tracking
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        gameState.addWord("burger")
        
        gameState.startGame()
        gameState.beginRound()
        
        // Play a bit
        gameState.wordGuessed()
        
        // Reset the game
        gameState.resetGame()
        
        // Check that everything is reset properly
        XCTAssertEqual(gameState.wordManager.words.count, 0, "Words should be cleared")
        XCTAssertEqual(gameState.currentPhase, .setup, "Should be back to setup phase")
        XCTAssertEqual(gameState.scoreManager.team1Score, 0, "Team 1 score should be reset")
        XCTAssertEqual(gameState.scoreManager.team2Score, 0, "Team 2 score should be reset")
        XCTAssertEqual(gameState.roundManager.currentTeam, 1, "Should be back to team 1")
        XCTAssertEqual(gameState.roundManager.currentRound, .describe, "Should be back to describe round")
    }
} 