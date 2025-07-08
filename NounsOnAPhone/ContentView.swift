//
//  ContentView.swift
//  NounsOnAPhone
//
//  Created by Blake Pozolo on 6/25/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameState()

    var body: some View {
        Group {
            switch gameState.currentPhase {
            case .setup:
                SetupView(gameState: gameState)
            case .wordInput:
                WordInputView(gameState: gameState)
            case .gameOverview:
                GameOverviewView(gameState: gameState)
            case .playing:
                GamePlayView(gameState: gameState)
            case .roundTransition:
                RoundTransitionView(gameState: gameState)
            case .gameOver:
                GameOverView(gameState: gameState)
            }
        }
        .onChange(of: gameState.currentPhase) { oldPhase, newPhase in
            switch newPhase {
            case .setup, .wordInput, .gameOver:
                OrientationManager.shared.lock(to: .portrait)
            case .playing, .roundTransition, .gameOverview:
                OrientationManager.shared.lock(to: [.portrait, .landscapeLeft, .landscapeRight])
            }
        }
        .onAppear {
            switch gameState.currentPhase {
            case .setup, .wordInput, .gameOver:
                OrientationManager.shared.lock(to: .portrait)
            case .playing, .roundTransition, .gameOverview:
                OrientationManager.shared.lock(to: [.portrait, .landscapeLeft, .landscapeRight])
            }
        }
    }
}

#Preview {
    ContentView()
}
