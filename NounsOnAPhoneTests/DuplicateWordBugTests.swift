import XCTest
@testable import NounsOnAPhone

final class DuplicateWordBugTests: XCTestCase {
    var gameState: GameState!
    
    override func setUp() {
        super.setUp()
        gameState = GameState()
    }
    
    override func tearDown() {
        gameState = nil
        super.tearDown()
    }
    
    // MARK: - Bug Test 1: Duplicate Word Tracking Inconsistency
    
    func testDuplicateWordTrackingInconsistency() {
        // This test checks for the bug where the game might not properly track
        // which specific instance of a duplicate word has been used
        
        // Add multiple instances of the same word
        gameState.addWord("pizza")
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
                // Check if this specific word instance has been used before
                let isAlreadyUsed = usedWordIds.contains(word.id)
                XCTAssertFalse(isAlreadyUsed, "Should not get the same word instance twice")
                
                usedWordIds.insert(word.id)
                gameState.wordGuessed()
                currentWord = gameState.wordManager.currentWord
            }
        }
        
        // Should have used exactly 4 unique word instances
        XCTAssertEqual(usedWordIds.count, 4, "Should use exactly 4 unique word instances")
    }
    
    // MARK: - Bug Test 2: Round Used Words Set vs Word.used Property Inconsistency
    
    func testRoundUsedWordIdsVsWordUsedPropertyConsistency() {
        // This test checks for consistency between roundUsedWordIds (Set<UUID>) 
        // and the Word.used property when dealing with duplicates
        
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        gameState.addWord("burger")
        
        gameState.startGame()
        gameState.beginRound()
        
        // Guess the first word
        let firstWord = gameState.wordManager.currentWord
        gameState.wordGuessed()
        
        // Check that the word is marked as used in the words array
        let usedWordsInArray = gameState.wordManager.words.filter { $0.used }
        XCTAssertTrue(usedWordsInArray.contains { $0.id == firstWord?.id }, 
                     "Word should be marked as used in the words array")
        
        // Continue guessing to see if tracking remains consistent
        while gameState.wordManager.currentWord != nil {
            let currentWord = gameState.wordManager.currentWord
            gameState.wordGuessed()
            
            // Check that the word is properly marked as used
            let usedWords = gameState.wordManager.words.filter { $0.used }
            XCTAssertTrue(usedWords.contains { $0.id == currentWord?.id }, 
                         "Each guessed word should be marked as used")
        }
    }
    
    // MARK: - Bug Test 3: Word Removal Logic with Duplicates
    
    func testWordRemovalLogicWithDuplicates() {
        // This test checks for bugs in the word removal logic when duplicates exist
        
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        gameState.addWord("burger")
        
        gameState.startGame()
        gameState.beginRound()
        
        var guessedWords: [String] = []
        
        // Guess words and track what we get
        while gameState.wordManager.currentWord != nil {
            let currentWord = gameState.wordManager.currentWord?.text ?? ""
            guessedWords.append(currentWord)
            gameState.wordGuessed()
        }
        
        // Should have guessed exactly 3 words (2 pizza + 1 burger)
        XCTAssertEqual(guessedWords.count, 3, "Should guess exactly 3 words")
        
        // Should have both pizza instances and burger
        let pizzaCount = guessedWords.filter { $0 == "pizza" }.count
        let burgerCount = guessedWords.filter { $0 == "burger" }.count
        
        XCTAssertEqual(pizzaCount, 2, "Should guess pizza exactly 2 times")
        XCTAssertEqual(burgerCount, 1, "Should guess burger exactly 1 time")
    }
    
    // MARK: - Bug Test 4: Score Calculation with Duplicates
    
    func testScoreCalculationWithDuplicates() {
        // This test checks for bugs in score calculation when duplicate words are guessed
        
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
        
        // Should get 1 point for each word guessed, regardless of duplicates
        XCTAssertEqual(scoreIncrease, wordsGuessed, "Score should increase by 1 for each word guessed")
        XCTAssertEqual(scoreIncrease, 4, "Should get exactly 4 points for 4 words")
    }
    
    // MARK: - Bug Test 5: Round Transition Logic with Duplicates
    
    func testRoundTransitionLogicWithDuplicates() {
        // This test checks for bugs in round transition logic when duplicates exist
        
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
    
    // MARK: - Bug Test 6: Timer Expiration with Duplicates
    
    func testTimerExpirationWithDuplicates() {
        // This test checks for bugs when timer expires with duplicate words
        
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        gameState.addWord("burger")
        
        // Set a very short timer before starting the game
        gameState.timerManager.updateTimerDuration(1)
        
        gameState.startGame()
        gameState.beginRound()
        
        // Wait for timer to expire (simulate by calling timerExpired directly)
        // Note: We can't directly call timerExpired as it's private, so we'll test the behavior
        // by checking that the game state is properly set up for timer expiration
        
        XCTAssertEqual(gameState.roundManager.currentTeam, 1, "Should start with team 1")
        XCTAssertTrue(gameState.timerManager.isTimerRunning, "Timer should be running")
        XCTAssertEqual(gameState.timerManager.timerDuration, 1, "Timer duration should be set to 1 second")
    }
    
    // MARK: - Bug Test 7: Word Selection Randomness with Duplicates
    
    func testWordSelectionRandomnessWithDuplicates() {
        // This test checks that word selection remains random even with duplicates
        
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        gameState.addWord("burger")
        
        gameState.startGame()
        gameState.beginRound()
        
        var selectedWords: [String] = []
        
        // Collect several word selections
        for _ in 0..<10 {
            if let currentWord = gameState.wordManager.currentWord {
                selectedWords.append(currentWord.text)
            }
            gameState.wordGuessed()
            
            // Reset for next iteration if no more words
            if gameState.wordManager.currentWord == nil {
                gameState.advanceTeamOrRound()
            }
        }
        
        // Should have selected from both pizza and burger
        let uniqueWords = Set(selectedWords)
        XCTAssertTrue(uniqueWords.contains("pizza"), "Should select pizza at least once")
        XCTAssertTrue(uniqueWords.contains("burger"), "Should select burger at least once")
    }
    
    // MARK: - Bug Test 8: Game Reset with Duplicates
    
    func testGameResetWithDuplicates() {
        // This test checks that game reset works properly with duplicate words
        
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
    
    // MARK: - Bug Test 9: Edge Case: All Duplicate Words
    
    func testAllDuplicateWords() {
        // This test checks the edge case where all words are duplicates
        
        for _ in 0..<10 {
            gameState.addWord("pizza")
        }
        
        XCTAssertTrue(gameState.canStartGame(), "Should be able to start game with all duplicate words")
        
        gameState.startGame()
        gameState.beginRound()
        
        // Should be able to play with all pizza words
        XCTAssertNotNil(gameState.wordManager.currentWord, "Should have a current word")
        XCTAssertEqual(gameState.wordManager.currentWord?.text, "pizza", "Current word should be pizza")
        
        // Should be able to guess multiple times
        var guessCount = 0
        while gameState.wordManager.currentWord != nil && guessCount < 10 {
            gameState.wordGuessed()
            guessCount += 1
        }
        
        XCTAssertEqual(guessCount, 10, "Should be able to guess exactly 10 times")
    }
    
    // MARK: - Bug Test 10: Case Sensitivity Edge Cases
    
    func testCaseSensitivityEdgeCases() {
        // This test checks edge cases with case sensitivity and duplicates
        
        gameState.addWord("Pizza")
        gameState.addWord("pizza")
        gameState.addWord("PIZZA")
        gameState.addWord("PiZzA")
        
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
        
        // Should have guessed all 4 different case variations
        XCTAssertEqual(guessedWords.count, 4, "Should guess all 4 case variations")
        XCTAssertTrue(guessedWords.contains("Pizza"), "Should guess 'Pizza'")
        XCTAssertTrue(guessedWords.contains("pizza"), "Should guess 'pizza'")
        XCTAssertTrue(guessedWords.contains("PIZZA"), "Should guess 'PIZZA'")
        XCTAssertTrue(guessedWords.contains("PiZzA"), "Should guess 'PiZzA'")
    }
} 