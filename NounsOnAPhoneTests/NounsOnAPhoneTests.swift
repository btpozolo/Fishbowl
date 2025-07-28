//
//  NounsOnAPhoneTests.swift
//  NounsOnAPhoneTests
//
//  Created by Blake Pozolo on 6/25/25.
//

import Testing
@testable import NounsOnAPhone

struct NounsOnAPhoneTests {

    @Test func gameStateTimerManagerIntegration() async throws {
        let gameState = GameState()
        
        // Test that GameState properly initializes with TimerManager
        #expect(gameState.timerManager.timeRemaining == 60)
        #expect(gameState.timerManager.timerDuration == 60)
        #expect(gameState.timerManager.isTimerRunning == false)
    }
    
    @Test func gameStateTimerDurationUpdates() async throws {
        let gameState = GameState()
        
        // Test that timer duration can be updated through GameState
        gameState.timerManager.updateTimerDuration(90)
        
        #expect(gameState.timerManager.timerDuration == 90)
        #expect(gameState.timerManager.timeRemaining == 90)
    }
    
    @Test func gameStateBasicFlow() async throws {
        let gameState = GameState()
        
        // Test basic game flow with timer integration
        gameState.addWord("pizza")
        gameState.addWord("burger")
        gameState.addWord("taco")
        
        #expect(gameState.canStartGame() == true)
        
        gameState.startGame()
        #expect(gameState.currentPhase == .gameOverview)
        
        gameState.beginRound()
        #expect(gameState.currentPhase == .playing)
        #expect(gameState.timerManager.isTimerRunning == true)
    }

}
