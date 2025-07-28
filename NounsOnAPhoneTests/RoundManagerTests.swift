import XCTest
@testable import NounsOnAPhone

final class RoundManagerTests: XCTestCase {
    var roundManager: RoundManager!
    
    override func setUp() {
        super.setUp()
        roundManager = RoundManager()
    }
    
    override func tearDown() {
        roundManager = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        XCTAssertEqual(roundManager.currentRound, .describe, "Should start with describe round")
        XCTAssertEqual(roundManager.currentTeam, 1, "Should start with team 1")
        XCTAssertNil(roundManager.lastTransitionReason, "Should start with no transition reason")
        XCTAssertTrue(roundManager.getAllUsedWordIds().isEmpty, "Should start with no used words")
    }
    
    // MARK: - Round Advancement Tests
    
    func testAdvanceFromDescribeToActOut() {
        XCTAssertEqual(roundManager.currentRound, .describe, "Should start in describe")
        
        roundManager.advanceRound()
        
        XCTAssertEqual(roundManager.currentRound, .actOut, "Should advance to act out")
        XCTAssertEqual(roundManager.lastTransitionReason, .wordsExhausted, "Should set transition reason")
        XCTAssertTrue(roundManager.getAllUsedWordIds().isEmpty, "Should clear used words")
    }
    
    func testAdvanceFromActOutToOneWord() {
        roundManager.currentRound = .actOut
        
        roundManager.advanceRound()
        
        XCTAssertEqual(roundManager.currentRound, .oneWord, "Should advance to one word")
        XCTAssertEqual(roundManager.lastTransitionReason, .wordsExhausted, "Should set transition reason")
    }
    
    func testAdvanceFromOneWordStaysAtOneWord() {
        roundManager.currentRound = .oneWord
        
        roundManager.advanceRound()
        
        XCTAssertEqual(roundManager.currentRound, .oneWord, "Should stay at one word (final round)")
        XCTAssertEqual(roundManager.lastTransitionReason, .wordsExhausted, "Should set transition reason")
    }
    
    func testFullRoundProgression() {
        XCTAssertEqual(roundManager.currentRound, .describe, "Start: describe")
        
        roundManager.advanceRound()
        XCTAssertEqual(roundManager.currentRound, .actOut, "Step 1: act out")
        
        roundManager.advanceRound()
        XCTAssertEqual(roundManager.currentRound, .oneWord, "Step 2: one word")
        
        roundManager.advanceRound()
        XCTAssertEqual(roundManager.currentRound, .oneWord, "Step 3: stays at one word")
    }
    
    // MARK: - Team Switching Tests
    
    func testSwitchFromTeam1ToTeam2() {
        XCTAssertEqual(roundManager.currentTeam, 1, "Should start with team 1")
        
        roundManager.switchTeam()
        
        XCTAssertEqual(roundManager.currentTeam, 2, "Should switch to team 2")
        XCTAssertEqual(roundManager.lastTransitionReason, .timerExpired, "Should set timer expired reason")
    }
    
    func testSwitchFromTeam2ToTeam1() {
        roundManager.currentTeam = 2
        
        roundManager.switchTeam()
        
        XCTAssertEqual(roundManager.currentTeam, 1, "Should switch to team 1")
        XCTAssertEqual(roundManager.lastTransitionReason, .timerExpired, "Should set timer expired reason")
    }
    
    func testMultipleTeamSwitches() {
        XCTAssertEqual(roundManager.currentTeam, 1, "Start: team 1")
        
        roundManager.switchTeam()
        XCTAssertEqual(roundManager.currentTeam, 2, "Switch 1: team 2")
        
        roundManager.switchTeam()
        XCTAssertEqual(roundManager.currentTeam, 1, "Switch 2: team 1")
        
        roundManager.switchTeam()
        XCTAssertEqual(roundManager.currentTeam, 2, "Switch 3: team 2")
    }
    
    // MARK: - Reset Tests
    
    func testResetToFirstRound() {
        // Set up some state
        roundManager.currentRound = .oneWord
        roundManager.currentTeam = 2
        roundManager.lastTransitionReason = .timerExpired
        roundManager.markWordUsedInRound(UUID())
        
        roundManager.resetToFirstRound()
        
        XCTAssertEqual(roundManager.currentRound, .describe, "Should reset to describe")
        XCTAssertEqual(roundManager.currentTeam, 1, "Should reset to team 1")
        XCTAssertNil(roundManager.lastTransitionReason, "Should clear transition reason")
        XCTAssertTrue(roundManager.getAllUsedWordIds().isEmpty, "Should clear used words")
    }
    
    // MARK: - Word Usage Tracking Tests
    
    func testMarkWordUsedInRound() {
        let wordId = UUID()
        XCTAssertFalse(roundManager.isWordUsedInRound(wordId), "Word should not be used initially")
        
        roundManager.markWordUsedInRound(wordId)
        
        XCTAssertTrue(roundManager.isWordUsedInRound(wordId), "Word should be marked as used")
        XCTAssertTrue(roundManager.getAllUsedWordIds().contains(wordId), "Used words should contain the word")
    }
    
    func testMultipleWordsUsedInRound() {
        let word1 = UUID()
        let word2 = UUID()
        let word3 = UUID()
        
        roundManager.markWordUsedInRound(word1)
        roundManager.markWordUsedInRound(word2)
        roundManager.markWordUsedInRound(word3)
        
        XCTAssertTrue(roundManager.isWordUsedInRound(word1), "Word 1 should be used")
        XCTAssertTrue(roundManager.isWordUsedInRound(word2), "Word 2 should be used")
        XCTAssertTrue(roundManager.isWordUsedInRound(word3), "Word 3 should be used")
        XCTAssertEqual(roundManager.getAllUsedWordIds().count, 3, "Should have 3 used words")
    }
    
    func testDuplicateWordUsage() {
        let wordId = UUID()
        
        roundManager.markWordUsedInRound(wordId)
        roundManager.markWordUsedInRound(wordId) // Mark same word again
        
        XCTAssertEqual(roundManager.getAllUsedWordIds().count, 1, "Should only have 1 unique word")
        XCTAssertTrue(roundManager.isWordUsedInRound(wordId), "Word should still be marked as used")
    }
    
    func testHasUsedAllWords() {
        XCTAssertFalse(roundManager.hasUsedAllWords(totalWords: 3), "Should not have used all words initially")
        
        roundManager.markWordUsedInRound(UUID())
        XCTAssertFalse(roundManager.hasUsedAllWords(totalWords: 3), "Should not have used all 3 words")
        
        roundManager.markWordUsedInRound(UUID())
        XCTAssertFalse(roundManager.hasUsedAllWords(totalWords: 3), "Should not have used all 3 words")
        
        roundManager.markWordUsedInRound(UUID())
        XCTAssertTrue(roundManager.hasUsedAllWords(totalWords: 3), "Should have used all 3 words")
    }
    
    func testCanAdvanceRound() {
        // Test in describe round
        XCTAssertFalse(roundManager.canAdvanceRound(wordsUsed: 2, totalWords: 3), "Cannot advance with partial words")
        XCTAssertTrue(roundManager.canAdvanceRound(wordsUsed: 3, totalWords: 3), "Can advance with all words used")
        
        // Test in act out round
        roundManager.currentRound = .actOut
        XCTAssertTrue(roundManager.canAdvanceRound(wordsUsed: 3, totalWords: 3), "Can advance from act out")
        
        // Test in final round
        roundManager.currentRound = .oneWord
        XCTAssertFalse(roundManager.canAdvanceRound(wordsUsed: 3, totalWords: 3), "Cannot advance from final round")
    }
    
    // MARK: - Convenience Methods Tests
    
    func testIsFirstRound() {
        XCTAssertTrue(roundManager.isFirstRound(), "Should be first round initially")
        
        roundManager.advanceRound()
        XCTAssertFalse(roundManager.isFirstRound(), "Should not be first round after advance")
        
        roundManager.resetToFirstRound()
        XCTAssertTrue(roundManager.isFirstRound(), "Should be first round after reset")
    }
    
    func testIsFinalRound() {
        XCTAssertFalse(roundManager.isFinalRound(), "Should not be final round initially")
        
        roundManager.currentRound = .oneWord
        XCTAssertTrue(roundManager.isFinalRound(), "Should be final round when in one word")
    }
    
    func testGetRoundDisplayName() {
        XCTAssertEqual(roundManager.getRoundDisplayName(), "Describe", "Describe round name")
        
        roundManager.currentRound = .actOut
        XCTAssertEqual(roundManager.getRoundDisplayName(), "Act Out", "Act out round name")
        
        roundManager.currentRound = .oneWord
        XCTAssertEqual(roundManager.getRoundDisplayName(), "One Word", "One word round name")
    }
    
    func testGetTeamDisplayName() {
        XCTAssertEqual(roundManager.getTeamDisplayName(), "Team 1", "Team 1 display name")
        
        roundManager.currentTeam = 2
        XCTAssertEqual(roundManager.getTeamDisplayName(), "Team 2", "Team 2 display name")
    }
    
    func testGetOpposingTeam() {
        XCTAssertEqual(roundManager.getOpposingTeam(), 2, "Opposing team should be 2 when current is 1")
        
        roundManager.currentTeam = 2
        XCTAssertEqual(roundManager.getOpposingTeam(), 1, "Opposing team should be 1 when current is 2")
    }
    
    func testGetNextRound() {
        XCTAssertEqual(roundManager.getNextRound(), .actOut, "Next round from describe should be act out")
        
        roundManager.currentRound = .actOut
        XCTAssertEqual(roundManager.getNextRound(), .oneWord, "Next round from act out should be one word")
        
        roundManager.currentRound = .oneWord
        XCTAssertNil(roundManager.getNextRound(), "No next round from one word")
    }
    
    func testGetRoundProgress() {
        var progress = roundManager.getRoundProgress()
        XCTAssertEqual(progress.current, 1, "Describe should be round 1")
        XCTAssertEqual(progress.total, 3, "Total rounds should be 3")
        
        roundManager.currentRound = .actOut
        progress = roundManager.getRoundProgress()
        XCTAssertEqual(progress.current, 2, "Act out should be round 2")
        XCTAssertEqual(progress.total, 3, "Total rounds should be 3")
        
        roundManager.currentRound = .oneWord
        progress = roundManager.getRoundProgress()
        XCTAssertEqual(progress.current, 3, "One word should be round 3")
        XCTAssertEqual(progress.total, 3, "Total rounds should be 3")
    }
    
    // MARK: - Integration Scenarios Tests
    
    func testCompleteGameScenario() {
        // Start game
        XCTAssertEqual(roundManager.currentRound, .describe, "Start in describe")
        XCTAssertEqual(roundManager.currentTeam, 1, "Start with team 1")
        
        // Team 1 plays in describe round
        let word1 = UUID()
        let word2 = UUID()
        roundManager.markWordUsedInRound(word1)
        roundManager.markWordUsedInRound(word2)
        
        // Timer expires, switch to team 2
        roundManager.switchTeam()
        XCTAssertEqual(roundManager.currentTeam, 2, "Switch to team 2")
        
        // Team 2 finishes remaining words
        let word3 = UUID()
        roundManager.markWordUsedInRound(word3)
        
        // All words used, advance round
        roundManager.advanceRound()
        XCTAssertEqual(roundManager.currentRound, .actOut, "Advance to act out")
        XCTAssertTrue(roundManager.getAllUsedWordIds().isEmpty, "Words cleared for new round")
        
        // Continue playing in act out round...
        roundManager.markWordUsedInRound(word1) // Same words, different round
        roundManager.markWordUsedInRound(word2)
        roundManager.markWordUsedInRound(word3)
        
        // Advance to final round
        roundManager.advanceRound()
        XCTAssertEqual(roundManager.currentRound, .oneWord, "Advance to final round")
        
        // Play final round
        roundManager.markWordUsedInRound(word1)
        roundManager.markWordUsedInRound(word2)
        roundManager.markWordUsedInRound(word3)
        
        // Game should end (no more rounds)
        XCTAssertTrue(roundManager.isFinalRound(), "Should be in final round")
        XCTAssertNil(roundManager.getNextRound(), "No next round available")
    }
    
    // MARK: - Edge Cases Tests
    
    func testZeroWords() {
        XCTAssertTrue(roundManager.hasUsedAllWords(totalWords: 0), "Should handle zero words")
        XCTAssertTrue(roundManager.canAdvanceRound(wordsUsed: 0, totalWords: 0), "Can advance with zero words")
    }
    
    func testLargeNumberOfWords() {
        let wordCount = 1000
        
        // Mark many words as used
        for _ in 0..<wordCount {
            roundManager.markWordUsedInRound(UUID())
        }
        
        XCTAssertEqual(roundManager.getAllUsedWordIds().count, wordCount, "Should handle large word count")
        XCTAssertTrue(roundManager.hasUsedAllWords(totalWords: wordCount), "Should detect all words used")
    }
    
    func testPerformanceWithManyWords() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Test performance with many word operations
        for _ in 0..<10000 {
            let wordId = UUID()
            roundManager.markWordUsedInRound(wordId)
            _ = roundManager.isWordUsedInRound(wordId)
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        
        XCTAssertLessThan(duration, 1.0, "10,000 word operations should take less than 1 second")
    }
    
    // MARK: - State Consistency Tests
    
    func testStateConsistencyAfterMultipleOperations() {
        // Perform various operations
        roundManager.switchTeam()
        roundManager.advanceRound()
        roundManager.markWordUsedInRound(UUID())
        roundManager.switchTeam()
        roundManager.markWordUsedInRound(UUID())
        
        // Verify state is consistent
        XCTAssertTrue([1, 2].contains(roundManager.currentTeam), "Team should be 1 or 2")
        XCTAssertTrue([.describe, .actOut, .oneWord].contains(roundManager.currentRound), "Round should be valid")
        XCTAssertEqual(roundManager.getAllUsedWordIds().count, 2, "Should track word usage correctly")
    }
} 