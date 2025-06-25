# Nouns on a Phone

A fun party game iOS app built with SwiftUI where teams take turns guessing words through different challenges.

## Game Overview

"Nouns on a Phone" is a multiplayer word-guessing game with three exciting rounds:

1. **Round 1: Describe the Word** - Describe the word to your team without saying the word itself
2. **Round 2: Act Out the Word** - Act out the word using gestures and body language  
3. **Round 3: One Word Only** - Describe the word using only one word

## Features

- **Word Input Phase**: Add custom words to your game or use sample words for quick testing
- **60-Second Timer**: Each team gets 60 seconds per round to guess as many words as possible
- **Team Scoring**: Track scores for two teams throughout all three rounds
- **Word Management**: Each word appears only once per round (unless time runs out)
- **Smooth Transitions**: Beautiful animations between game phases
- **Final Results**: See which team wins and play again option

## How to Play

1. **Setup**: Add words to your game (minimum 3 words required)
2. **Overview**: Review the three rounds and their rules
3. **Gameplay**: Teams take turns with 60-second rounds
4. **Scoring**: Tap "Correct!" when a word is guessed successfully
5. **Results**: See final scores and winner at the end

## Technical Details

- Built with SwiftUI for iOS
- Uses MVVM architecture with ObservableObject for state management
- Responsive design that works on all iPhone sizes
- Clean, modern UI with smooth animations

## Files Structure

- `GameModels.swift` - Core game logic and state management
- `WordInputView.swift` - Word input interface
- `GameOverviewView.swift` - Game rules and round introduction
- `GamePlayView.swift` - Main gameplay interface with timer and scoring
- `RoundTransitionView.swift` - Team transition screens
- `GameOverView.swift` - Final results and replay option
- `ContentView.swift` - Main app coordinator
- `SampleWords.swift` - Helper for testing with sample words

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Getting Started

1. Open the project in Xcode
2. Select your target device or simulator
3. Build and run the app
4. Start by adding words or using sample words for testing
5. Enjoy playing with friends and family!

## Game Rules

- Each team gets 60 seconds per round
- Words can only be used once per round (unless time expires)
- Teams alternate turns between rounds
- The team with the highest total score after all three rounds wins
- In case of a tie, both teams are celebrated as winners 