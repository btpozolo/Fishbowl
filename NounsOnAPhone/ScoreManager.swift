import Foundation

// MARK: - Score Manager Protocol
protocol ScoreManagerProtocol: ObservableObject {
    var team1Score: Int { get }
    var team2Score: Int { get }
    var team1TurnScores: [Int] { get }
    var team2TurnScores: [Int] { get }
    var teamTurnCount: [Int: Int] { get }
    
    func incrementScore(for team: Int)
    func resetScores()
    func getWinner() -> Int?
    func recordTeamTurnScore(for team: Int, score: Int)
    func getCurrentScore(for team: Int) -> Int
}

// MARK: - Score Manager Implementation
class ScoreManager: ObservableObject, ScoreManagerProtocol {
    @Published var team1Score: Int = 0
    @Published var team2Score: Int = 0
    @Published var team1TurnScores: [Int] = [0] // Always start with 0
    @Published var team2TurnScores: [Int] = [0] // Always start with 0
    @Published var teamTurnCount: [Int: Int] = [1: 0, 2: 0] // Track how many turns each team has taken
    
    func incrementScore(for team: Int) {
        if team == 1 {
            team1Score += 1
        } else {
            team2Score += 1
        }
        teamTurnCount[team, default: 0] += 1
    }
    
    func resetScores() {
        team1Score = 0
        team2Score = 0
        team1TurnScores = [0]
        team2TurnScores = [0]
        teamTurnCount = [1: 0, 2: 0]
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
    
    func recordTeamTurnScore(for team: Int, score: Int) {
        if team == 1 {
            team1TurnScores.append(score)
        } else {
            team2TurnScores.append(score)
        }
    }
    
    func getCurrentScore(for team: Int) -> Int {
        return team == 1 ? team1Score : team2Score
    }
    
    // MARK: - Convenience Methods
    
    func recordCurrentTeamTurnScore(currentTeam: Int) {
        recordTeamTurnScore(for: currentTeam, score: getCurrentScore(for: currentTeam))
    }
    
    func getScoreDifference() -> Int {
        return abs(team1Score - team2Score)
    }
    
    func isGameTied() -> Bool {
        return team1Score == team2Score
    }
    
    func getTotalScore() -> Int {
        return team1Score + team2Score
    }
} 