import XCTest
@testable import NounsOnAPhone

final class DuplicateWordTests: XCTestCase {
    var gameState: GameState!
    
    override func setUp() {
        super.setUp()
        gameState = GameState()
    }
    
    override func tearDown() {
        gameState = nil
        super.tearDown()
    }
    
    // MARK: - Duplicate Word Input Tests
    
    func testAddDuplicateWords() {
        // Test that duplicate words can be added
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        
        XCTAssertEqual(gameState.words.count, 3, "Should allow duplicate words to be added")
        XCTAssertEqual(gameState.words.filter { $0.text == "pizza" }.count, 3, "Should have 3 instances of 'pizza'")
    }
    
    func testAddDuplicateWordsWithDifferentCasing() {
        // Test case sensitivity
        gameState.addWord("Pizza")
        gameState.addWord("pizza")
        gameState.addWord("PIZZA")
        
        XCTAssertEqual(gameState.words.count, 3, "Should treat different cases as different words")
        XCTAssertEqual(gameState.words.filter { $0.text == "Pizza" }.count, 1, "Should have 1 instance of 'Pizza'")
        XCTAssertEqual(gameState.words.filter { $0.text == "pizza" }.count, 1, "Should have 1 instance of 'pizza'")
        XCTAssertEqual(gameState.words.filter { $0.text == "PIZZA" }.count, 1, "Should have 1 instance of 'PIZZA'")
    }
    
    func testAddDuplicateWordsWithWhitespace() {
        // Test whitespace handling
        gameState.addWord("pizza")
        gameState.addWord(" pizza ")
        gameState.addWord("pizza")
        
        XCTAssertEqual(gameState.words.count, 3, "Should treat words with different whitespace as different")
        XCTAssertEqual(gameState.words.filter { $0.text == "pizza" }.count, 2, "Should have 2 instances of 'pizza'")
        XCTAssertEqual(gameState.words.filter { $0.text == " pizza " }.count, 1, "Should have 1 instance of ' pizza '")
    }
    
    // MARK: - Game Flow with Duplicate Words Tests
    
    func testStartGameWithDuplicateWords() {
        // Add duplicate words and start game
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        gameState.addWord("burger")
        
        XCTAssertTrue(gameState.canStartGame(), "Should be able to start game with duplicate words")
        
        gameState.startGame()
        XCTAssertEqual(gameState.currentPhase, .gameOverview, "Should transition to game overview")
    }
    
    func testRoundSetupWithDuplicateWords() {
        // Setup game with duplicates
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        gameState.addWord("burger")
        gameState.startGame()
        gameState.beginRound()
        
        // Check that all words (including duplicates) are available for the round
        XCTAssertEqual(gameState.currentPhase, .playing, "Should be in playing phase")
        XCTAssertNotNil(gameState.currentWord, "Should have a current word")
        
        // The word should be one of the added words
        let validWords = ["pizza", "burger"]
        XCTAssertTrue(validWords.contains(gameState.currentWord?.text ?? ""), "Current word should be one of the valid words")
    }
    
    // MARK: - Word Guessing with Duplicates Tests
    
    func testGuessDuplicateWord() {
        // Setup game with duplicates
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        gameState.addWord("burger")
        gameState.startGame()
        gameState.beginRound()
        
        let initialWord = gameState.currentWord?.text
        
        // Guess the word
        gameState.wordGuessed()
        
        // Check that the word is marked as used in the round
        XCTAssertTrue(gameState.words.filter { $0.text == initialWord }.contains { $0.used }, "Word should be marked as used")
        
        // Check that roundUsedWords contains the word
        // Note: We can't directly access roundUsedWords as it's private, but we can infer from behavior
        XCTAssertNotEqual(gameState.currentWord?.text, initialWord, "Should have a different word after guessing")
    }
    
    func testGuessAllInstancesOfDuplicateWord() {
        // Setup game with multiple instances of the same word
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        gameState.addWord("burger")
        gameState.startGame()
        gameState.beginRound()
        
        // Guess "pizza" multiple times
        var pizzaGuessed = 0
        var currentWord = gameState.currentWord?.text
        
        while currentWord == "pizza" && pizzaGuessed < 3 {
            gameState.wordGuessed()
            pizzaGuessed += 1
            currentWord = gameState.currentWord?.text
        }
        
        // Should have guessed pizza up to 3 times (once for each instance)
        XCTAssertLessThanOrEqual(pizzaGuessed, 3, "Should be able to guess pizza up to 3 times")
        
        // After all pizzas are guessed, should either have burger or no more words
        if gameState.currentWord != nil {
            XCTAssertEqual(gameState.currentWord?.text, "burger", "Should have burger as the remaining word")
        }
    }
    
    // MARK: - Score Tracking with Duplicates Tests
    
    func testScoreIncrementWithDuplicateWords() {
        // Setup game with duplicates
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        gameState.addWord("burger")
        gameState.startGame()
        gameState.beginRound()
        
        let initialScore = gameState.team1Score
        
        // Guess a word
        gameState.wordGuessed()
        
        XCTAssertEqual(gameState.team1Score, initialScore + 1, "Score should increment by 1 for each guessed word")
    }
    
    // MARK: - Round Transition with Duplicates Tests
    
    func testRoundTransitionWithDuplicateWords() {
        // Setup game with duplicates
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        gameState.addWord("burger")
        gameState.startGame()
        gameState.beginRound()
        
        // Guess all words
        while gameState.currentWord != nil {
            gameState.wordGuessed()
        }
        
        // Should transition to next round or game over
        XCTAssertTrue(gameState.currentPhase == .roundTransition || gameState.currentPhase == .gameOver, "Should transition appropriately after all words guessed")
    }
    
    // MARK: - Edge Cases with Duplicates Tests
    
    func testEmptyWordInput() {
        // Test adding empty or whitespace-only words
        gameState.addWord("")
        gameState.addWord("   ")
        gameState.addWord("\n\t")
        
        XCTAssertEqual(gameState.words.count, 0, "Should not add empty or whitespace-only words")
    }
    
    func testSingleWordGame() {
        // Test game with only one unique word (multiple instances)
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        
        XCTAssertTrue(gameState.canStartGame(), "Should be able to start game with only one unique word")
        
        gameState.startGame()
        gameState.beginRound()
        
        // Should be able to play with the same word multiple times
        XCTAssertNotNil(gameState.currentWord, "Should have a current word")
        XCTAssertEqual(gameState.currentWord?.text, "pizza", "Current word should be pizza")
    }
    
    func testWordRemovalAfterGuessing() {
        // Test that words are properly removed from the pool after guessing
        gameState.addWord("pizza")
        gameState.addWord("pizza")
        gameState.addWord("burger")
        gameState.startGame()
        gameState.beginRound()
        
        // Guess the first word
        let firstWord = gameState.currentWord?.text
        gameState.wordGuessed()
        
        // The second word should be different (unless it's the same word type)
        let secondWord = gameState.currentWord?.text
        
        // If we guessed pizza and there's another pizza, we might get pizza again
        // But if we guessed burger, we should get a different word
        if firstWord == "burger" {
            XCTAssertNotEqual(secondWord, "burger", "Should not get burger again immediately")
        }
    }
    
    // MARK: - Performance Tests with Many Duplicates
    
    func testPerformanceWithManyDuplicates() {
        // Test performance with many duplicate words
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<100 {
            gameState.addWord("pizza")
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        
        XCTAssertEqual(gameState.words.count, 100, "Should add 100 instances of pizza")
        XCTAssertLessThan(duration, 1.0, "Adding 100 duplicate words should take less than 1 second")
    }
    
    // MARK: - Memory Tests with Duplicates
    
    func testMemoryUsageWithDuplicates() {
        // Test that adding many duplicates doesn't cause memory issues
        let initialMemory = getMemoryUsage()
        
        for _ in 0..<1000 {
            gameState.addWord("pizza")
        }
        
        let finalMemory = getMemoryUsage()
        let memoryIncrease = finalMemory - initialMemory
        
        XCTAssertEqual(gameState.words.count, 1000, "Should add 1000 instances of pizza")
        XCTAssertLessThan(memoryIncrease, 10 * 1024 * 1024, "Memory increase should be less than 10MB for 1000 words")
    }
    
    // MARK: - Helper Methods
    
    private func getMemoryUsage() -> Int {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Int(info.resident_size)
        } else {
            return 0
        }
    }
} 