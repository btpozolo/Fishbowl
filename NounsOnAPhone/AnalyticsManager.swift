import Foundation

// MARK: - Analytics Manager Protocol
protocol AnalyticsManagerProtocol: ObservableObject {
    // Published properties for UI binding
    var skipsByWord: [UUID: Int] { get }
    var timeSpentByWord: [UUID: Int] { get }
    var roundStats: [RoundType: (team1Time: Int, team2Time: Int, team1Correct: Int, team2Correct: Int)] { get }
    
    // Core analytics methods
    func recordWordSkip(wordId: UUID)
    func recordWordTime(wordId: UUID, timeSpent: Int)
    func recordCorrectGuess(for team: Int, in round: RoundType)
    func recordTimeForCurrentRound(team: Int, round: RoundType)
    
    // Round management
    func initializeRoundStats(for round: RoundType)
    func recordRoundStartTime(for team: Int, round: RoundType)
    
    // Data generation
    func getWordStatistics(from words: [Word]) -> [GameState.WordStat]
    func getWordsPerMinuteData() -> [GameState.WordsPerMinuteData]
    func getOverallWordsPerMinute() -> (team1WPM: Double?, team2WPM: Double?)
    
    // Lifecycle
    func resetAnalytics()
}

// MARK: - Analytics Manager Implementation
class AnalyticsManager: ObservableObject, AnalyticsManagerProtocol {
    // MARK: - Published Properties
    @Published var skipsByWord: [UUID: Int] = [:]
    @Published var timeSpentByWord: [UUID: Int] = [:]
    @Published var roundStats: [RoundType: (team1Time: Int, team2Time: Int, team1Correct: Int, team2Correct: Int)] = [:]
    
    // MARK: - Private Properties
    /// Track when each team started each round for accurate WPM calculation
    private var teamRoundStartTimes: [Int: [RoundType: Date]] = [1: [:], 2: [:]]
    
    /// Flag to prevent double-counting turn time
    private var turnTimeAlreadyAdded: Bool = false
    
    // MARK: - Core Analytics Methods
    
    /// Record that a word was skipped
    /// - Parameter wordId: The unique identifier of the skipped word
    func recordWordSkip(wordId: UUID) {
        skipsByWord[wordId, default: 0] += 1
    }
    
    /// Record time spent on a word
    /// - Parameters:
    ///   - wordId: The unique identifier of the word
    ///   - timeSpent: Time spent on the word in seconds
    func recordWordTime(wordId: UUID, timeSpent: Int) {
        timeSpentByWord[wordId, default: 0] += timeSpent
    }
    
    /// Record a correct guess for a team in a specific round
    /// - Parameters:
    ///   - team: Team number (1 or 2)
    ///   - round: The round type where the guess occurred
    func recordCorrectGuess(for team: Int, in round: RoundType) {
        // Ensure round stats exist
        if roundStats[round] == nil {
            initializeRoundStats(for: round)
        }
        
        if team == 1 {
            roundStats[round]?.team1Correct += 1
        } else {
            roundStats[round]?.team2Correct += 1
        }
    }
    
    /// Record time spent by current team in current round
    /// - Parameters:
    ///   - team: Team number (1 or 2)
    ///   - round: The round type
    func recordTimeForCurrentRound(team: Int, round: RoundType) {
        guard !turnTimeAlreadyAdded else { return }
        
        if let roundStartTime = teamRoundStartTimes[team]?[round] {
            let timeSpentInRound = Int(Date().timeIntervalSince(roundStartTime))
            
            // Ensure round stats exist
            if roundStats[round] == nil {
                initializeRoundStats(for: round)
            }
            
            if team == 1 {
                roundStats[round]?.team1Time += timeSpentInRound
            } else {
                roundStats[round]?.team2Time += timeSpentInRound
            }
            
            // Reset the round start time for this team/round since we recorded the time
            teamRoundStartTimes[team]?[round] = Date()
            turnTimeAlreadyAdded = true
        }
    }
    
    // MARK: - Round Management
    
    /// Initialize statistics tracking for a new round
    /// - Parameter round: The round type to initialize
    func initializeRoundStats(for round: RoundType) {
        roundStats[round] = (team1Time: 0, team2Time: 0, team1Correct: 0, team2Correct: 0)
    }
    
    /// Record when a team starts a round for time tracking
    /// - Parameters:
    ///   - team: Team number (1 or 2)
    ///   - round: The round type being started
    func recordRoundStartTime(for team: Int, round: RoundType) {
        // Initialize team tracking if needed
        if teamRoundStartTimes[team] == nil {
            teamRoundStartTimes[team] = [:]
        }
        
        // Only set start time if this team hasn't started this round yet
        if teamRoundStartTimes[team]?[round] == nil {
            teamRoundStartTimes[team]?[round] = Date()
        }
        
        // Reset the flag at the start of each turn
        turnTimeAlreadyAdded = false
    }
    
    // MARK: - Data Generation
    
    /// Generate word statistics showing performance per word
    /// - Parameter words: Array of words to analyze
    /// - Returns: Array of word statistics sorted by average time (slowest first)
    func getWordStatistics(from words: [Word]) -> [GameState.WordStat] {
        var stats: [GameState.WordStat] = []
        
        for word in words {
            let skips = skipsByWord[word.id] ?? 0
            let totalTime = timeSpentByWord[word.id] ?? 0
            
            // Only include words that were actually played (have time spent or skips)
            // This filters out words that were never displayed during the game
            if totalTime > 0 || skips > 0 {
                // Calculate average time: total time divided by 3 (since each word appears in 3 rounds)
                let averageTime = Double(totalTime) / 3.0
                
                stats.append(GameState.WordStat(
                    word: word,
                    skips: skips,
                    averageTime: averageTime,
                    totalTime: totalTime
                ))
            }
        }
        
        // Sort by average time descending (slowest words first)
        return stats.sorted { $0.averageTime > $1.averageTime }
    }
    
    /// Generate Words Per Minute data for each round and team
    /// - Returns: Array of WPM data per round
    func getWordsPerMinuteData() -> [GameState.WordsPerMinuteData] {
        var wpmData: [GameState.WordsPerMinuteData] = []
        
        for round in RoundType.allCases {
            if let stats = roundStats[round] {
                let team1WPM: Double? = stats.team1Time > 0 ? Double(stats.team1Correct) / (Double(stats.team1Time) / 60.0) : nil
                let team2WPM: Double? = stats.team2Time > 0 ? Double(stats.team2Correct) / (Double(stats.team2Time) / 60.0) : nil
                
                wpmData.append(GameState.WordsPerMinuteData(
                    round: round,
                    team1WPM: team1WPM,
                    team2WPM: team2WPM
                ))
            }
        }
        
        return wpmData
    }
    
    /// Calculate overall Words Per Minute across all rounds
    /// - Returns: Tuple containing WPM for both teams (nil if no data)
    func getOverallWordsPerMinute() -> (team1WPM: Double?, team2WPM: Double?) {
        var team1TotalTime = 0
        var team2TotalTime = 0
        var team1TotalCorrect = 0
        var team2TotalCorrect = 0
        
        for (_, stats) in roundStats {
            team1TotalTime += stats.team1Time
            team2TotalTime += stats.team2Time
            team1TotalCorrect += stats.team1Correct
            team2TotalCorrect += stats.team2Correct
        }
        
        let team1WPM: Double? = team1TotalTime > 0 ? Double(team1TotalCorrect) / (Double(team1TotalTime) / 60.0) : nil
        let team2WPM: Double? = team2TotalTime > 0 ? Double(team2TotalCorrect) / (Double(team2TotalTime) / 60.0) : nil
        
        return (team1WPM: team1WPM, team2WPM: team2WPM)
    }
    
    // MARK: - Lifecycle
    
    /// Reset all analytics data
    func resetAnalytics() {
        skipsByWord.removeAll()
        timeSpentByWord.removeAll()
        roundStats.removeAll()
        teamRoundStartTimes = [1: [:], 2: [:]]
        turnTimeAlreadyAdded = false
    }
} 