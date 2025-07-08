import XCTest
@testable import NounsOnAPhone

final class WordStatisticsTests: XCTestCase {
    var gameState: GameState!
    
    override func setUp() {
        super.setUp()
        gameState = GameState()
    }
    
    override func tearDown() {
        gameState = nil
        super.tearDown()
    }
    
    // MARK: - Word Statistics Tests
    
    func testWordStatisticsCalculation() {
        // Add some test words
        gameState.addWord("Pizza")
        gameState.addWord("Elephant")
        gameState.addWord("Basketball")
        
        // Simulate some game data
        let pizzaWord = gameState.words.first { $0.text == "Pizza" }!
        let elephantWord = gameState.words.first { $0.text == "Elephant" }!
        let basketballWord = gameState.words.first { $0.text == "Basketball" }!
        
        // Simulate time spent and skips
        gameState.timeSpentByWord[pizzaWord.id] = 30 // 30 seconds total
        gameState.timeSpentByWord[elephantWord.id] = 90 // 90 seconds total
        gameState.timeSpentByWord[basketballWord.id] = 45 // 45 seconds total
        
        gameState.skipsByWord[pizzaWord.id] = 0 // No skips
        gameState.skipsByWord[elephantWord.id] = 2 // 2 skips
        gameState.skipsByWord[basketballWord.id] = 1 // 1 skip
        
        // Get statistics
        let stats = gameState.getWordStatistics()
        
        // Verify we have 3 stats
        XCTAssertEqual(stats.count, 3, "Should have 3 word statistics")
        
        // Verify sorting (should be sorted by average time descending)
        XCTAssertEqual(stats[0].word.text, "Elephant", "Elephant should be first (slowest)")
        XCTAssertEqual(stats[1].word.text, "Basketball", "Basketball should be second")
        XCTAssertEqual(stats[2].word.text, "Pizza", "Pizza should be last (fastest)")
        
        // Verify average time calculations
        XCTAssertEqual(stats[0].averageTime, 30.0, "Elephant average time should be 30 seconds")
        XCTAssertEqual(stats[1].averageTime, 15.0, "Basketball average time should be 15 seconds")
        XCTAssertEqual(stats[2].averageTime, 10.0, "Pizza average time should be 10 seconds")
        
        // Verify skip counts
        XCTAssertEqual(stats[0].skips, 2, "Elephant should have 2 skips")
        XCTAssertEqual(stats[1].skips, 1, "Basketball should have 1 skip")
        XCTAssertEqual(stats[2].skips, 0, "Pizza should have 0 skips")
    }
    
    func testWordStatisticsWithNoData() {
        // Add words but no game data
        gameState.addWord("Pizza")
        gameState.addWord("Elephant")
        
        let stats = gameState.getWordStatistics()
        
        // Should still have stats with zero values
        XCTAssertEqual(stats.count, 2, "Should have 2 word statistics")
        
        for stat in stats {
            XCTAssertEqual(stat.skips, 0, "Should have 0 skips")
            XCTAssertEqual(stat.averageTime, 0.0, "Should have 0 average time")
            XCTAssertEqual(stat.totalTime, 0, "Should have 0 total time")
        }
    }
    
    func testWordStatisticsReset() {
        // Add words and simulate some data
        gameState.addWord("Pizza")
        let pizzaWord = gameState.words.first { $0.text == "Pizza" }!
        gameState.timeSpentByWord[pizzaWord.id] = 30
        gameState.skipsByWord[pizzaWord.id] = 1
        
        // Verify data exists
        XCTAssertEqual(gameState.getWordStatistics().count, 1, "Should have 1 stat before reset")
        
        // Reset game
        gameState.resetGame()
        
        // Verify data is cleared
        XCTAssertEqual(gameState.getWordStatistics().count, 0, "Should have 0 stats after reset")
        XCTAssertTrue(gameState.timeSpentByWord.isEmpty, "Time data should be cleared")
        XCTAssertTrue(gameState.skipsByWord.isEmpty, "Skip data should be cleared")
    }
    
    func testWordStatisticsWithPartialData() {
        // Add words
        gameState.addWord("Pizza")
        gameState.addWord("Elephant")
        
        let pizzaWord = gameState.words.first { $0.text == "Pizza" }!
        let elephantWord = gameState.words.first { $0.text == "Elephant" }!
        
        // Only add time data for one word
        gameState.timeSpentByWord[pizzaWord.id] = 60
        gameState.skipsByWord[elephantWord.id] = 2
        
        let stats = gameState.getWordStatistics()
        
        // Should have stats for both words
        XCTAssertEqual(stats.count, 2, "Should have 2 word statistics")
        
        // Find the stats for each word
        let pizzaStat = stats.first { $0.word.text == "Pizza" }!
        let elephantStat = stats.first { $0.word.text == "Elephant" }!
        
        // Verify pizza has time but no skips
        XCTAssertEqual(pizzaStat.averageTime, 20.0, "Pizza average time should be 20 seconds")
        XCTAssertEqual(pizzaStat.skips, 0, "Pizza should have 0 skips")
        
        // Verify elephant has skips but no time
        XCTAssertEqual(elephantStat.averageTime, 0.0, "Elephant average time should be 0")
        XCTAssertEqual(elephantStat.skips, 2, "Elephant should have 2 skips")
    }
} 