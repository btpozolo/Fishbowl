import Testing
@testable import NounsOnAPhone
import Foundation

struct GameCoordinatorTests {
    
    // MARK: - Initial State Tests
    
    @Test func gameCoordinatorInitialState() async throws {
        let coordinator = GameCoordinator()
        
        #expect(coordinator.currentPhase == .setup)
        #expect(coordinator.timerManager.timeRemaining == 60)
        #expect(coordinator.scoreManager.team1Score == 0)
        #expect(coordinator.roundManager.currentRound == .describe)
        #expect(coordinator.wordManager.words.isEmpty)
        #expect(coordinator.analyticsManager.roundStats.isEmpty)
    }
    
    @Test func managerInstancesExist() async throws {
        let coordinator = GameCoordinator()
        
        // Verify all manager instances exist by testing basic properties
        #expect(coordinator.timerManager.timeRemaining >= 0)
        #expect(coordinator.scoreManager.team1Score >= 0)
        #expect(coordinator.roundManager.currentTeam >= 1)
        #expect(coordinator.wordManager.words.count >= 0)
        #expect(coordinator.analyticsManager.skipsByWord.count >= 0)
    }
    
    // MARK: - Phase Management Tests
    
    @Test func proceedToWordInput() async throws {
        let coordinator = GameCoordinator()
        
        coordinator.proceedToWordInput()
        #expect(coordinator.currentPhase == .wordInput)
    }
    
    @Test func goToSetupView() async throws {
        let coordinator = GameCoordinator()
        
        coordinator.currentPhase = .playing
        coordinator.goToSetupView()
        #expect(coordinator.currentPhase == .setupView)
    }
    
    @Test func startGame() async throws {
        let coordinator = GameCoordinator()
        
        // Set up some state first
        coordinator.scoreManager.incrementScore(for: 1)
        coordinator.roundManager.currentRound = .actOut
        coordinator.analyticsManager.recordWordSkip(wordId: UUID())
        
        coordinator.startGame()
        
        #expect(coordinator.currentPhase == .gameOverview)
        #expect(coordinator.scoreManager.team1Score == 0) // Should reset
        #expect(coordinator.roundManager.currentRound == .describe) // Should reset
        #expect(coordinator.analyticsManager.skipsByWord.isEmpty) // Should reset
    }
    
    @Test func beginRound() async throws {
        let coordinator = GameCoordinator()
        
        // Add words so the game can begin
        coordinator.addWord("pizza")
        coordinator.addWord("burger")
        coordinator.addWord("taco")
        
        coordinator.beginRound()
        
        #expect(coordinator.currentPhase == .playing)
        #expect(coordinator.timerManager.timeRemaining == coordinator.timerManager.timerDuration)
        #expect(coordinator.wordManager.currentWord != nil)
    }
    
    // MARK: - Word Management Tests
    
    @Test func addWord() async throws {
        let coordinator = GameCoordinator()
        
        coordinator.addWord("pizza")
        #expect(coordinator.wordManager.words.count == 1)
        #expect(coordinator.wordManager.words.first?.text == "pizza")
    }
    
    @Test func addDuplicateWord() async throws {
        let coordinator = GameCoordinator()
        
        coordinator.addWord("pizza")
        coordinator.addWord("pizza") // Should be allowed to add duplicate (no validation at coordinator level)
        
        #expect(coordinator.wordManager.words.count == 2) // WordManager addWord doesn't prevent duplicates
    }
    
    @Test func canStartGame() async throws {
        let coordinator = GameCoordinator()
        
        #expect(!coordinator.canStartGame())
        
        coordinator.addWord("pizza")
        coordinator.addWord("burger")
        #expect(!coordinator.canStartGame())
        
        coordinator.addWord("taco")
        #expect(coordinator.canStartGame())
    }
    
    // MARK: - Game Flow Tests
    
    @Test func wordGuessed() async throws {
        let coordinator = GameCoordinator()
        
        // Setup game
        coordinator.addWord("pizza")
        coordinator.addWord("burger")
        coordinator.addWord("taco")
        coordinator.beginRound()
        
        let initialScore = coordinator.scoreManager.team1Score
        let currentWord = coordinator.wordManager.currentWord
        
        coordinator.wordGuessed()
        
        // Verify score increased
        #expect(coordinator.scoreManager.team1Score == initialScore + 1)
        
        // Verify analytics recorded
        let describeStats = coordinator.analyticsManager.roundStats[.describe]
        #expect(describeStats?.team1Correct == 1)
        
        // Verify new word selected or game progressed
        #expect(coordinator.wordManager.currentWord?.id != currentWord?.id || coordinator.currentPhase != .playing)
    }
    
    @Test func wordGuessedLastWord() async throws {
        let coordinator = GameCoordinator()
        
        // Setup with only one word
        coordinator.addWord("pizza")
        coordinator.addWord("burger")
        coordinator.addWord("taco")
        coordinator.beginRound()
        
        // Guess all words
        while coordinator.wordManager.hasUnusedWords() && coordinator.currentPhase == .playing {
            coordinator.wordGuessed()
        }
        
        // Should transition to next phase
        #expect(coordinator.currentPhase != .playing)
    }
    
    @Test func skipCurrentWord() async throws {
        let coordinator = GameCoordinator()
        
        coordinator.addWord("pizza")
        coordinator.addWord("burger")
        coordinator.addWord("taco")
        coordinator.addWord("pasta")
        coordinator.beginRound()
        
        let currentWordId = coordinator.wordManager.currentWord?.id
        
        coordinator.skipCurrentWord()
        
        // Verify word changed
        #expect(coordinator.wordManager.currentWord?.id != currentWordId)
        
        // Verify skip was recorded
        if let wordId = currentWordId {
            #expect(coordinator.analyticsManager.skipsByWord[wordId] == 1)
        }
    }
    
    @Test func advanceTeamOrRound() async throws {
        let coordinator = GameCoordinator()
        
        coordinator.addWord("pizza")
        coordinator.addWord("burger")
        coordinator.addWord("taco")
        coordinator.beginRound()
        
        let initialTeam = coordinator.roundManager.currentTeam
        
        coordinator.advanceTeamOrRound(wordsExhausted: false)
        
        // Should switch teams or advance round
        let newTeam = coordinator.roundManager.currentTeam
        #expect(newTeam != initialTeam || coordinator.currentPhase == .roundTransition)
    }
    
    // MARK: - Timer Integration Tests
    
    @Test func timerManagerDelegateSetup() async throws {
        let coordinator = GameCoordinator()
        
        // Verify delegate is set
        #expect(coordinator.timerManager.delegate != nil)
    }
    
    @Test func timerExpiredHandling() async throws {
        let coordinator = GameCoordinator()
        
        coordinator.addWord("pizza")
        coordinator.addWord("burger")
        coordinator.addWord("taco")
        coordinator.beginRound()
        
        // Simulate timer expiration
        coordinator.timerManager.delegate?.timerDidExpire()
        
        // Should handle timer expiration
        #expect(coordinator.currentPhase == .roundTransition || coordinator.currentPhase == .gameOver)
    }
    
    // MARK: - WordManager Integration Tests
    
    @Test func wordManagerDelegateSetup() async throws {
        let coordinator = GameCoordinator()
        
        // Verify delegate is set
        #expect(coordinator.wordManager.delegate != nil)
    }
    
    @Test func wordManagerSkipDelegate() async throws {
        let coordinator = GameCoordinator()
        let wordId = UUID()
        
        // Simulate word skip through delegate
        coordinator.wordManager.delegate?.wordManager(coordinator.wordManager, didSkipWord: wordId)
        
        // Verify analytics recorded the skip
        #expect(coordinator.analyticsManager.skipsByWord[wordId] == 1)
    }
    
    @Test func wordManagerTimeDelegate() async throws {
        let coordinator = GameCoordinator()
        let wordId = UUID()
        let timeSpent = 5
        
        // Simulate time spent through delegate
        coordinator.wordManager.delegate?.wordManager(coordinator.wordManager, didSpendTime: timeSpent, onWord: wordId)
        
        // Verify analytics recorded the time
        #expect(coordinator.analyticsManager.timeSpentByWord[wordId] == timeSpent)
    }
    
    // MARK: - Analytics Integration Tests
    
    @Test func getWordStatistics() async throws {
        let coordinator = GameCoordinator()
        
        coordinator.addWord("pizza")
        coordinator.addWord("burger")
        
        // Record some analytics data
        let wordId = coordinator.wordManager.words.first?.id ?? UUID()
        coordinator.analyticsManager.recordWordSkip(wordId: wordId)
        coordinator.analyticsManager.recordWordTime(wordId: wordId, timeSpent: 10)
        
        let stats = coordinator.getWordStatistics()
        #expect(stats.count >= 1)
    }
    
    @Test func getWordsPerMinuteData() async throws {
        let coordinator = GameCoordinator()
        
        // Setup analytics data
        coordinator.analyticsManager.initializeRoundStats(for: .describe)
        coordinator.analyticsManager.roundStats[.describe] = (team1Time: 60, team2Time: 0, team1Correct: 6, team2Correct: 0)
        
        let wpmData = coordinator.getWordsPerMinuteData()
        #expect(!wpmData.isEmpty)
        
        let describeData = wpmData.first { $0.round == .describe }
        #expect(describeData?.team1WPM == 6.0)
    }
    
    // MARK: - Round Transition Tests
    
    @Test func beginNextTurn() async throws {
        let coordinator = GameCoordinator()
        
        coordinator.addWord("pizza")
        coordinator.addWord("burger")
        coordinator.addWord("taco")
        coordinator.startGame()
        
        coordinator.beginNextTurn()
        
        #expect(coordinator.currentPhase == .playing)
        #expect(coordinator.timerManager.isTimerRunning == true)
    }
    
    @Test func setupRoundWithUsedWords() async throws {
        let coordinator = GameCoordinator()
        
        coordinator.addWord("pizza")
        coordinator.addWord("burger")
        coordinator.addWord("taco")
        
        // Mark some words as used in previous round
        let wordId = coordinator.wordManager.words.first?.id ?? UUID()
        coordinator.roundManager.markWordUsedInRound(wordId)
        
        coordinator.beginRound()
        
        // Should have set up the round with used words filtered
        #expect(coordinator.wordManager.currentWord != nil)
    }
    
    // MARK: - Edge Cases Tests
    
    @Test func wordGuessedWithNoCurrentWord() async throws {
        let coordinator = GameCoordinator()
        
        // Don't add any words or begin round
        let initialScore = coordinator.scoreManager.team1Score
        
        coordinator.wordGuessed()
        
        // Should not crash or change score
        #expect(coordinator.scoreManager.team1Score == initialScore)
    }
    
    @Test func skipWithNoWords() async throws {
        let coordinator = GameCoordinator()
        
        // Should not crash
        coordinator.skipCurrentWord()
        #expect(coordinator.wordManager.currentWord == nil)
    }
    
    @Test func advanceFromLastRound() async throws {
        let coordinator = GameCoordinator()
        
        coordinator.addWord("pizza")
        coordinator.addWord("burger")
        coordinator.addWord("taco")
        
        // Set to last round
        coordinator.roundManager.currentRound = .oneWord
        coordinator.beginRound()
        
        // Use all words
        while coordinator.wordManager.hasUnusedWords() {
            coordinator.wordGuessed()
            if coordinator.currentPhase != .playing {
                break
            }
        }
        
        // Should end game
        #expect(coordinator.currentPhase == .gameOver || coordinator.currentPhase == .roundTransition)
    }
    
    // MARK: - Manager Coordination Tests
    
    @Test func managersWorkTogether() async throws {
        let coordinator = GameCoordinator()
        
        // Setup full game flow
        coordinator.addWord("pizza")
        coordinator.addWord("burger")
        coordinator.addWord("taco")
        coordinator.addWord("pasta")
        
        coordinator.startGame()
        coordinator.beginRound()
        
        // Play through some actions
        coordinator.wordGuessed()
        coordinator.skipCurrentWord()
        coordinator.wordGuessed()
        
        // Verify all managers have been updated
        #expect(coordinator.scoreManager.team1Score > 0) // Score updated
        #expect(coordinator.analyticsManager.roundStats[.describe]?.team1Correct ?? 0 > 0) // Analytics updated
        #expect(!coordinator.analyticsManager.skipsByWord.isEmpty) // Skip recorded
        #expect(coordinator.wordManager.currentWord != nil) // Word manager active
    }
    
    @Test func fullGameFlow() async throws {
        let coordinator = GameCoordinator()
        
        // Add minimum words
        coordinator.addWord("pizza")
        coordinator.addWord("burger")
        coordinator.addWord("taco")
        
        // Full flow: setup -> word input -> game overview -> playing
        #expect(coordinator.currentPhase == .setup)
        
        coordinator.proceedToWordInput()
        #expect(coordinator.currentPhase == .wordInput)
        
        coordinator.startGame()
        #expect(coordinator.currentPhase == .gameOverview)
        
        coordinator.beginRound()
        #expect(coordinator.currentPhase == .playing)
        
        // Play until end
        var safetyCounter = 100 // Prevent infinite loop
        while coordinator.currentPhase == .playing && safetyCounter > 0 {
            coordinator.wordGuessed()
            safetyCounter -= 1
        }
        
        #expect(coordinator.currentPhase != .playing)
        #expect(safetyCounter > 0) // Ensure we didn't hit infinite loop
    }
} 