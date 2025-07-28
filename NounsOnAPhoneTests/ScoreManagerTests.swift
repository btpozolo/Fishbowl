import XCTest
@testable import NounsOnAPhone

final class ScoreManagerTests: XCTestCase {
    var scoreManager: ScoreManager!
    
    override func setUp() {
        super.setUp()
        scoreManager = ScoreManager()
    }
    
    override func tearDown() {
        scoreManager = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        XCTAssertEqual(scoreManager.team1Score, 0, "Team 1 score should start at 0")
        XCTAssertEqual(scoreManager.team2Score, 0, "Team 2 score should start at 0")
        XCTAssertEqual(scoreManager.team1TurnScores, [0], "Team 1 turn scores should start with [0]")
        XCTAssertEqual(scoreManager.team2TurnScores, [0], "Team 2 turn scores should start with [0]")
        XCTAssertEqual(scoreManager.teamTurnCount[1], 0, "Team 1 turn count should start at 0")
        XCTAssertEqual(scoreManager.teamTurnCount[2], 0, "Team 2 turn count should start at 0")
    }
    
    // MARK: - Score Increment Tests
    
    func testIncrementScoreTeam1() {
        scoreManager.incrementScore(for: 1)
        
        XCTAssertEqual(scoreManager.team1Score, 1, "Team 1 score should be 1 after increment")
        XCTAssertEqual(scoreManager.team2Score, 0, "Team 2 score should remain 0")
        XCTAssertEqual(scoreManager.teamTurnCount[1], 1, "Team 1 turn count should be 1")
    }
    
    func testIncrementScoreTeam2() {
        scoreManager.incrementScore(for: 2)
        
        XCTAssertEqual(scoreManager.team2Score, 1, "Team 2 score should be 1 after increment")
        XCTAssertEqual(scoreManager.team1Score, 0, "Team 1 score should remain 0")
        XCTAssertEqual(scoreManager.teamTurnCount[2], 1, "Team 2 turn count should be 1")
    }
    
    func testMultipleIncrements() {
        scoreManager.incrementScore(for: 1)
        scoreManager.incrementScore(for: 1)
        scoreManager.incrementScore(for: 2)
        
        XCTAssertEqual(scoreManager.team1Score, 2, "Team 1 score should be 2")
        XCTAssertEqual(scoreManager.team2Score, 1, "Team 2 score should be 1")
        XCTAssertEqual(scoreManager.teamTurnCount[1], 2, "Team 1 turn count should be 2")
        XCTAssertEqual(scoreManager.teamTurnCount[2], 1, "Team 2 turn count should be 1")
    }
    
    func testIncrementInvalidTeam() {
        scoreManager.incrementScore(for: 3) // Invalid team
        
        XCTAssertEqual(scoreManager.team1Score, 0, "Team 1 score should remain 0")
        XCTAssertEqual(scoreManager.team2Score, 0, "Team 2 score should remain 0")
        XCTAssertEqual(scoreManager.teamTurnCount[3], 1, "Invalid team turn count should be tracked")
    }
    
    // MARK: - Get Current Score Tests
    
    func testGetCurrentScore() {
        scoreManager.incrementScore(for: 1)
        scoreManager.incrementScore(for: 1)
        scoreManager.incrementScore(for: 2)
        
        XCTAssertEqual(scoreManager.getCurrentScore(for: 1), 2, "Should return current team 1 score")
        XCTAssertEqual(scoreManager.getCurrentScore(for: 2), 1, "Should return current team 2 score")
    }
    
    func testGetCurrentScoreInvalidTeam() {
        XCTAssertEqual(scoreManager.getCurrentScore(for: 3), 0, "Should return 0 for invalid team")
    }
    
    // MARK: - Winner Determination Tests
    
    func testGetWinnerTeam1() {
        scoreManager.team1Score = 5
        scoreManager.team2Score = 3
        
        XCTAssertEqual(scoreManager.getWinner(), 1, "Team 1 should be the winner")
    }
    
    func testGetWinnerTeam2() {
        scoreManager.team1Score = 2
        scoreManager.team2Score = 4
        
        XCTAssertEqual(scoreManager.getWinner(), 2, "Team 2 should be the winner")
    }
    
    func testGetWinnerTie() {
        scoreManager.team1Score = 3
        scoreManager.team2Score = 3
        
        XCTAssertNil(scoreManager.getWinner(), "Should return nil for tie")
    }
    
    func testGetWinnerBothZero() {
        XCTAssertNil(scoreManager.getWinner(), "Should return nil when both teams have 0")
    }
    
    // MARK: - Turn Score Recording Tests
    
    func testRecordTeamTurnScoreTeam1() {
        scoreManager.recordTeamTurnScore(for: 1, score: 5)
        
        XCTAssertEqual(scoreManager.team1TurnScores, [0, 5], "Team 1 turn scores should include new score")
        XCTAssertEqual(scoreManager.team2TurnScores, [0], "Team 2 turn scores should remain unchanged")
    }
    
    func testRecordTeamTurnScoreTeam2() {
        scoreManager.recordTeamTurnScore(for: 2, score: 3)
        
        XCTAssertEqual(scoreManager.team2TurnScores, [0, 3], "Team 2 turn scores should include new score")
        XCTAssertEqual(scoreManager.team1TurnScores, [0], "Team 1 turn scores should remain unchanged")
    }
    
    func testRecordMultipleTurnScores() {
        scoreManager.recordTeamTurnScore(for: 1, score: 3)
        scoreManager.recordTeamTurnScore(for: 2, score: 2)
        scoreManager.recordTeamTurnScore(for: 1, score: 6)
        
        XCTAssertEqual(scoreManager.team1TurnScores, [0, 3, 6], "Team 1 should have multiple turn scores")
        XCTAssertEqual(scoreManager.team2TurnScores, [0, 2], "Team 2 should have one turn score")
    }
    
    func testRecordCurrentTeamTurnScore() {
        scoreManager.team1Score = 5
        scoreManager.team2Score = 3
        
        scoreManager.recordCurrentTeamTurnScore(currentTeam: 1)
        scoreManager.recordCurrentTeamTurnScore(currentTeam: 2)
        
        XCTAssertEqual(scoreManager.team1TurnScores, [0, 5], "Team 1 turn scores should include current score")
        XCTAssertEqual(scoreManager.team2TurnScores, [0, 3], "Team 2 turn scores should include current score")
    }
    
    // MARK: - Reset Tests
    
    func testResetScores() {
        // Set up some scores
        scoreManager.team1Score = 5
        scoreManager.team2Score = 3
        scoreManager.team1TurnScores = [0, 2, 5]
        scoreManager.team2TurnScores = [0, 1, 3]
        scoreManager.teamTurnCount = [1: 3, 2: 2]
        
        scoreManager.resetScores()
        
        XCTAssertEqual(scoreManager.team1Score, 0, "Team 1 score should be reset to 0")
        XCTAssertEqual(scoreManager.team2Score, 0, "Team 2 score should be reset to 0")
        XCTAssertEqual(scoreManager.team1TurnScores, [0], "Team 1 turn scores should be reset to [0]")
        XCTAssertEqual(scoreManager.team2TurnScores, [0], "Team 2 turn scores should be reset to [0]")
        XCTAssertEqual(scoreManager.teamTurnCount[1], 0, "Team 1 turn count should be reset to 0")
        XCTAssertEqual(scoreManager.teamTurnCount[2], 0, "Team 2 turn count should be reset to 0")
    }
    
    // MARK: - Convenience Methods Tests
    
    func testGetScoreDifference() {
        scoreManager.team1Score = 7
        scoreManager.team2Score = 3
        
        XCTAssertEqual(scoreManager.getScoreDifference(), 4, "Score difference should be 4")
        
        scoreManager.team1Score = 2
        scoreManager.team2Score = 5
        
        XCTAssertEqual(scoreManager.getScoreDifference(), 3, "Score difference should be 3")
    }
    
    func testGetScoreDifferenceTie() {
        scoreManager.team1Score = 4
        scoreManager.team2Score = 4
        
        XCTAssertEqual(scoreManager.getScoreDifference(), 0, "Score difference should be 0 for tie")
    }
    
    func testIsGameTied() {
        scoreManager.team1Score = 3
        scoreManager.team2Score = 3
        
        XCTAssertTrue(scoreManager.isGameTied(), "Game should be tied")
        
        scoreManager.team2Score = 4
        
        XCTAssertFalse(scoreManager.isGameTied(), "Game should not be tied")
    }
    
    func testGetTotalScore() {
        scoreManager.team1Score = 5
        scoreManager.team2Score = 3
        
        XCTAssertEqual(scoreManager.getTotalScore(), 8, "Total score should be 8")
        
        scoreManager.team1Score = 0
        scoreManager.team2Score = 0
        
        XCTAssertEqual(scoreManager.getTotalScore(), 0, "Total score should be 0")
    }
    
    // MARK: - Integration Tests
    
    func testFullGameScenario() {
        // Simulate a full game scenario
        
        // Round 1 - Team 1's turn
        scoreManager.incrementScore(for: 1)
        scoreManager.incrementScore(for: 1)
        scoreManager.incrementScore(for: 1)
        scoreManager.recordCurrentTeamTurnScore(currentTeam: 1)
        
        // Round 1 - Team 2's turn  
        scoreManager.incrementScore(for: 2)
        scoreManager.incrementScore(for: 2)
        scoreManager.recordCurrentTeamTurnScore(currentTeam: 2)
        
        // Round 2 - Team 1's turn
        scoreManager.incrementScore(for: 1)
        scoreManager.recordCurrentTeamTurnScore(currentTeam: 1)
        
        // Round 2 - Team 2's turn
        scoreManager.incrementScore(for: 2)
        scoreManager.incrementScore(for: 2)
        scoreManager.incrementScore(for: 2)
        scoreManager.recordCurrentTeamTurnScore(currentTeam: 2)
        
        // Verify final state
        XCTAssertEqual(scoreManager.team1Score, 4, "Team 1 final score should be 4")
        XCTAssertEqual(scoreManager.team2Score, 5, "Team 2 final score should be 5")
        XCTAssertEqual(scoreManager.getWinner(), 2, "Team 2 should win")
        XCTAssertEqual(scoreManager.team1TurnScores, [0, 3, 4], "Team 1 turn progression")
        XCTAssertEqual(scoreManager.team2TurnScores, [0, 2, 5], "Team 2 turn progression")
        XCTAssertEqual(scoreManager.teamTurnCount[1], 4, "Team 1 total turns")
        XCTAssertEqual(scoreManager.teamTurnCount[2], 5, "Team 2 total turns")
    }
    
    // MARK: - Edge Cases Tests
    
    func testNegativeTeamNumbers() {
        scoreManager.incrementScore(for: -1)
        scoreManager.incrementScore(for: 0)
        
        // Should not affect team 1 or 2 scores
        XCTAssertEqual(scoreManager.team1Score, 0, "Team 1 score should remain 0")
        XCTAssertEqual(scoreManager.team2Score, 0, "Team 2 score should remain 0")
    }
    
    func testLargeScores() {
        // Test with large scores
        for _ in 0..<1000 {
            scoreManager.incrementScore(for: 1)
        }
        
        XCTAssertEqual(scoreManager.team1Score, 1000, "Should handle large scores correctly")
        XCTAssertEqual(scoreManager.teamTurnCount[1], 1000, "Should handle large turn counts")
    }
    
    func testPerformance() {
        // Test performance with many score increments
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for i in 0..<10000 {
            scoreManager.incrementScore(for: i % 2 == 0 ? 1 : 2)
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = endTime - startTime
        
        XCTAssertLessThan(duration, 1.0, "10,000 score increments should take less than 1 second")
        XCTAssertEqual(scoreManager.team1Score, 5000, "Team 1 should have 5000 points")
        XCTAssertEqual(scoreManager.team2Score, 5000, "Team 2 should have 5000 points")
    }
} 