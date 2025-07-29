//
//  ContentView.swift
//  NounsOnAPhone
//
//  Created by Blake Pozolo on 6/25/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameState()
    @State private var showLaunchScreen = true

    var body: some View {
        Group {
            if showLaunchScreen {
                // Launch screen - shows briefly then transitions to landing page
                LaunchScreenView()
                    .onAppear {
                        // Show launch screen for 2 seconds, then transition to app
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showLaunchScreen = false
                            }
                        }
                    }
            } else if gameState.currentPhase == .setup {
                // Use NavigationStack for setup/landing pages
                LandingPageView(gameState: gameState)
                    .onAppear {
                        OrientationManager.shared.lock(to: .portrait)
                    }
            } else {
                // Use old phase-based navigation for actual gameplay
                Group {
                    switch gameState.currentPhase {
                    case .setupView:
                        NavigationStack {
                            SetupView(gameState: gameState)
                        }
                    case .wordInput:
                        NavigationStack {
                            WordInputView(gameState: gameState)
                        }
                    case .gameOverview:
                        GameOverviewView(gameState: gameState)
                    case .playing:
                        GamePlayView(gameState: gameState)
                    case .roundTransition:
                        RoundTransitionView(gameState: gameState)
                    case .gameOver:
                        GameOverView(gameState: gameState)
                    case .setup:
                        // This case should not be reached due to the if condition above
                        EmptyView()
                    }
                }
                .onChange(of: gameState.currentPhase) { oldPhase, newPhase in
                    switch newPhase {
                    case .setup, .setupView, .wordInput, .gameOver:
                        OrientationManager.shared.lock(to: .portrait)
                    case .playing, .roundTransition, .gameOverview:
                        OrientationManager.shared.lock(to: [.portrait, .landscapeLeft, .landscapeRight])
                    }
                }
                .onAppear {
                    switch gameState.currentPhase {
                    case .setup, .setupView, .wordInput, .gameOver:
                        OrientationManager.shared.lock(to: .portrait)
                    case .playing, .roundTransition, .gameOverview:
                        OrientationManager.shared.lock(to: [.portrait, .landscapeLeft, .landscapeRight])
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
