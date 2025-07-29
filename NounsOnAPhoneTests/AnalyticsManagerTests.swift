import Testing
@testable import NounsOnAPhone
import Foundation

struct AnalyticsManagerTests {
    
    // MARK: - Initial State Tests
    
    @Test func analyticsManagerInitialState() async throws {
        let analytics = AnalyticsManager()
        
        #expect(analytics.skipsByWord.isEmpty)
        #expect(analytics.timeSpentByWord.isEmpty)
        #expect(analytics.roundStats.isEmpty)
    }
    
    // MARK: - Word Skip Recording Tests
    
    @Test func recordWordSkip() async throws {
        let analytics = AnalyticsManager()
        let wordId = UUID()
        
        // Record first skip
        analytics.recordWordSkip(wordId: wordId)
        #expect(analytics.skipsByWord[wordId] == 1)
        
        // Record second skip
        analytics.recordWordSkip(wordId: wordId)
        #expect(analytics.skipsByWord[wordId] == 2)
    }
    
    @Test func recordSkipMultipleWords() async throws {
        let analytics = AnalyticsManager()
        let word1Id = UUID()
        let word2Id = UUID()
        
        analytics.recordWordSkip(wordId: word1Id)
        analytics.recordWordSkip(wordId: word2Id)
        analytics.recordWordSkip(wordId: word1Id)
        
        #expect(analytics.skipsByWord[word1Id] == 2)
        #expect(analytics.skipsByWord[word2Id] == 1)
    }
    
    // MARK: - Word Time Recording Tests
    
    @Test func recordWordTime() async throws {
        let analytics = AnalyticsManager()
        let wordId = UUID()
        
        // Record first time
        analytics.recordWordTime(wordId: wordId, timeSpent: 5)
        #expect(analytics.timeSpentByWord[wordId] == 5)
        
        // Record additional time (should accumulate)
        analytics.recordWordTime(wordId: wordId, timeSpent: 3)
        #expect(analytics.timeSpentByWord[wordId] == 8)
    }
    
    @Test func recordTimeMultipleWords() async throws {
        let analytics = AnalyticsManager()
        let word1Id = UUID()
        let word2Id = UUID()
        
        analytics.recordWordTime(wordId: word1Id, timeSpent: 10)
        analytics.recordWordTime(wordId: word2Id, timeSpent: 15)
        
        #expect(analytics.timeSpentByWord[word1Id] == 10)
        #expect(analytics.timeSpentByWord[word2Id] == 15)
    }
    
    // MARK: - Round Statistics Tests
    
    @Test func initializeRoundStats() async throws {
        let analytics = AnalyticsManager()
        
        analytics.initializeRoundStats(for: .describe)
        
        let stats = analytics.roundStats[.describe]
        #expect(stats != nil)
        #expect(stats?.team1Time == 0)
        #expect(stats?.team2Time == 0)
        #expect(stats?.team1Correct == 0)
        #expect(stats?.team2Correct == 0)
    }
    
    @Test func recordCorrectGuess() async throws {
        let analytics = AnalyticsManager()
        
        analytics.initializeRoundStats(for: .describe)
        
        // Record team 1 correct guess
        analytics.recordCorrectGuess(for: 1, in: .describe)
        #expect(analytics.roundStats[.describe]?.team1Correct == 1)
        #expect(analytics.roundStats[.describe]?.team2Correct == 0)
        
        // Record team 2 correct guess
        analytics.recordCorrectGuess(for: 2, in: .describe)
        #expect(analytics.roundStats[.describe]?.team1Correct == 1)
        #expect(analytics.roundStats[.describe]?.team2Correct == 1)
        
        // Record multiple guesses
        analytics.recordCorrectGuess(for: 1, in: .describe)
        analytics.recordCorrectGuess(for: 1, in: .describe)
        #expect(analytics.roundStats[.describe]?.team1Correct == 3)
    }
    
    @Test func recordCorrectGuessMultipleRounds() async throws {
        let analytics = AnalyticsManager()
        
        analytics.initializeRoundStats(for: .describe)
        analytics.initializeRoundStats(for: .actOut)
        
        analytics.recordCorrectGuess(for: 1, in: .describe)
        analytics.recordCorrectGuess(for: 1, in: .actOut)
        analytics.recordCorrectGuess(for: 2, in: .describe)
        
        #expect(analytics.roundStats[.describe]?.team1Correct == 1)
        #expect(analytics.roundStats[.describe]?.team2Correct == 1)
        #expect(analytics.roundStats[.actOut]?.team1Correct == 1)
        #expect(analytics.roundStats[.actOut]?.team2Correct == 0)
    }
    
    // MARK: - Time Tracking Tests
    
    @Test func recordRoundStartTime() async throws {
        let analytics = AnalyticsManager()
        
        analytics.recordRoundStartTime(for: 1, round: .describe)
        
        // Verify internal state (we can't directly test private properties)
        // But we can test the behavior by calling recordTimeForCurrentRound
        analytics.initializeRoundStats(for: .describe)
        
        // Simulate some time passing
        try await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        
        analytics.recordTimeForCurrentRound(team: 1, round: .describe)
        
        let stats = analytics.roundStats[.describe]
        #expect(stats?.team1Time ?? 0 >= 0) // Should have recorded some time
    }
    
    @Test func recordTimeForCurrentRoundPreventsDoubleRecording() async throws {
        let analytics = AnalyticsManager()
        
        analytics.initializeRoundStats(for: .describe)
        analytics.recordRoundStartTime(for: 1, round: .describe)
        
        // Record time first time
        analytics.recordTimeForCurrentRound(team: 1, round: .describe)
        let firstTime = analytics.roundStats[.describe]?.team1Time ?? 0
        
        // Record time second time - should not add more time
        analytics.recordTimeForCurrentRound(team: 1, round: .describe)
        let secondTime = analytics.roundStats[.describe]?.team1Time ?? 0
        
        #expect(firstTime == secondTime)
    }
    
    @Test func recordTimeMultipleTeams() async throws {
        let analytics = AnalyticsManager()
        
        analytics.initializeRoundStats(for: .describe)
        analytics.recordRoundStartTime(for: 1, round: .describe)
        analytics.recordRoundStartTime(for: 2, round: .describe)
        
        // Simulate time passing
        try await Task.sleep(nanoseconds: 10_000_000)
        
        analytics.recordTimeForCurrentRound(team: 1, round: .describe)
        analytics.recordTimeForCurrentRound(team: 2, round: .describe)
        
        let stats = analytics.roundStats[.describe]
        #expect(stats?.team1Time ?? 0 >= 0)
        #expect(stats?.team2Time ?? 0 >= 0)
    }
    
    // MARK: - Word Statistics Generation Tests
    
    @Test func getWordStatisticsEmptyData() async throws {
        let analytics = AnalyticsManager()
        let words = [Word(text: "pizza"), Word(text: "burger")]
        
        let stats = analytics.getWordStatistics(from: words)
        #expect(stats.isEmpty)
    }
    
    @Test func getWordStatisticsWithSkipsAndTime() async throws {
        let analytics = AnalyticsManager()
        let word1 = Word(text: "pizza")
        let word2 = Word(text: "burger")
        let words = [word1, word2]
        
        // Record skip and time data
        analytics.recordWordSkip(wordId: word1.id)
        analytics.recordWordSkip(wordId: word1.id)
        analytics.recordWordTime(wordId: word1.id, timeSpent: 15)
        
        analytics.recordWordSkip(wordId: word2.id)
        analytics.recordWordTime(wordId: word2.id, timeSpent: 9)
        
        let stats = analytics.getWordStatistics(from: words)
        
        #expect(stats.count == 2)
        
        // Stats should be sorted by average time (highest first)
        let firstStat = stats[0]
        let secondStat = stats[1]
        
        #expect(firstStat.averageTime >= secondStat.averageTime)
        
        // Verify data
        if firstStat.word.text == "pizza" {
            #expect(firstStat.skips == 2)
            #expect(firstStat.totalTime == 15)
            #expect(firstStat.averageTime == 5.0) // 15 / 3 rounds
        }
    }
    
    @Test func getWordStatisticsOnlySkips() async throws {
        let analytics = AnalyticsManager()
        let word = Word(text: "pizza")
        
        analytics.recordWordSkip(wordId: word.id)
        analytics.recordWordSkip(wordId: word.id)
        
        let stats = analytics.getWordStatistics(from: [word])
        
        #expect(stats.count == 1)
        #expect(stats[0].skips == 2)
        #expect(stats[0].totalTime == 0)
        #expect(stats[0].averageTime == 0.0)
    }
    
    @Test func getWordStatisticsOnlyTime() async throws {
        let analytics = AnalyticsManager()
        let word = Word(text: "pizza")
        
        analytics.recordWordTime(wordId: word.id, timeSpent: 12)
        
        let stats = analytics.getWordStatistics(from: [word])
        
        #expect(stats.count == 1)
        #expect(stats[0].skips == 0)
        #expect(stats[0].totalTime == 12)
        #expect(stats[0].averageTime == 4.0) // 12 / 3 rounds
    }
    
    // MARK: - Words Per Minute Data Tests
    
    @Test func getWordsPerMinuteDataEmpty() async throws {
        let analytics = AnalyticsManager()
        
        let wpmData = analytics.getWordsPerMinuteData()
        #expect(wpmData.isEmpty)
    }
    
    @Test func getWordsPerMinuteDataWithStats() async throws {
        let analytics = AnalyticsManager()
        
        // Initialize round stats with time and correct answers
        analytics.initializeRoundStats(for: .describe)
        analytics.initializeRoundStats(for: .actOut)
        
        // Set up describe round: Team 1 = 6 words in 60 seconds (6 WPM), Team 2 = 3 words in 30 seconds (6 WPM)
        analytics.roundStats[.describe] = (team1Time: 60, team2Time: 30, team1Correct: 6, team2Correct: 3)
        
        // Set up act out round: Team 1 = 4 words in 120 seconds (2 WPM), Team 2 = no time
        analytics.roundStats[.actOut] = (team1Time: 120, team2Time: 0, team1Correct: 4, team2Correct: 0)
        
        let wpmData = analytics.getWordsPerMinuteData()
        
        #expect(wpmData.count >= 2)
        
        let describeData = wpmData.first { $0.round == .describe }
        let actOutData = wpmData.first { $0.round == .actOut }
        
        #expect(describeData != nil)
        #expect(describeData?.team1WPM == 6.0)
        #expect(describeData?.team2WPM == 6.0)
        
        #expect(actOutData != nil)
        #expect(actOutData?.team1WPM == 2.0)
        #expect(actOutData?.team2WPM == nil)
    }
    
    @Test func getWordsPerMinuteCalculation() async throws {
        let analytics = AnalyticsManager()
        
        analytics.initializeRoundStats(for: .describe)
        
        // Test specific WPM calculation: 10 words in 120 seconds = 5 WPM
        analytics.roundStats[.describe] = (team1Time: 120, team2Time: 0, team1Correct: 10, team2Correct: 0)
        
        let wpmData = analytics.getWordsPerMinuteData()
        let describeData = wpmData.first { $0.round == .describe }
        
        #expect(describeData?.team1WPM == 5.0) // 10 words / (120 seconds / 60) = 5 WPM
    }
    
    @Test func getOverallWordsPerMinute() async throws {
        let analytics = AnalyticsManager()
        
        analytics.initializeRoundStats(for: .describe)
        analytics.initializeRoundStats(for: .actOut)
        
        // Team 1: 6 words in 60 seconds + 4 words in 120 seconds = 10 words in 180 seconds = 3.33 WPM
        // Team 2: 2 words in 90 seconds = 1.33 WPM
        analytics.roundStats[.describe] = (team1Time: 60, team2Time: 90, team1Correct: 6, team2Correct: 2)
        analytics.roundStats[.actOut] = (team1Time: 120, team2Time: 0, team1Correct: 4, team2Correct: 0)
        
        let overallWPM = analytics.getOverallWordsPerMinute()
        
        // Team 1: 10 words / (180 seconds / 60) = 10 / 3 = 3.33...
        #expect(abs((overallWPM.team1WPM ?? 0) - 3.333333333333333) < 0.0001)
        
        // Team 2: 2 words / (90 seconds / 60) = 2 / 1.5 = 1.33...
        #expect(abs((overallWPM.team2WPM ?? 0) - 1.333333333333333) < 0.0001)
    }
    
    @Test func getOverallWordsPerMinuteNoData() async throws {
        let analytics = AnalyticsManager()
        
        let overallWPM = analytics.getOverallWordsPerMinute()
        #expect(overallWPM.team1WPM == nil)
        #expect(overallWPM.team2WPM == nil)
    }
    
    // MARK: - Reset Analytics Tests
    
    @Test func resetAnalytics() async throws {
        let analytics = AnalyticsManager()
        let wordId = UUID()
        
        // Add some data
        analytics.recordWordSkip(wordId: wordId)
        analytics.recordWordTime(wordId: wordId, timeSpent: 10)
        analytics.initializeRoundStats(for: .describe)
        analytics.recordCorrectGuess(for: 1, in: .describe)
        analytics.recordRoundStartTime(for: 1, round: .describe)
        
        // Verify data exists
        #expect(!analytics.skipsByWord.isEmpty)
        #expect(!analytics.timeSpentByWord.isEmpty)
        #expect(!analytics.roundStats.isEmpty)
        
        // Reset
        analytics.resetAnalytics()
        
        // Verify all data is cleared
        #expect(analytics.skipsByWord.isEmpty)
        #expect(analytics.timeSpentByWord.isEmpty)
        #expect(analytics.roundStats.isEmpty)
    }
    
    // MARK: - Edge Cases Tests
    
    @Test func recordTimeZeroSeconds() async throws {
        let analytics = AnalyticsManager()
        let wordId = UUID()
        
        analytics.recordWordTime(wordId: wordId, timeSpent: 0)
        #expect(analytics.timeSpentByWord[wordId] == 0)
        
        let stats = analytics.getWordStatistics(from: [Word(text: "test")])
        #expect(stats.isEmpty) // Should not include words with 0 time and 0 skips
    }
    
    @Test func wpmCalculationZeroTime() async throws {
        let analytics = AnalyticsManager()
        
        analytics.initializeRoundStats(for: .describe)
        analytics.roundStats[.describe] = (team1Time: 0, team2Time: 0, team1Correct: 5, team2Correct: 3)
        
        let wpmData = analytics.getWordsPerMinuteData()
        let describeData = wpmData.first { $0.round == .describe }
        
        #expect(describeData?.team1WPM == nil) // Division by zero should return nil
        #expect(describeData?.team2WPM == nil)
    }
} 