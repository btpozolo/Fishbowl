# Nouns on a Phone

A fun party game iOS app built with SwiftUI where teams take turns guessing words through different challenges.

## Game Overview

"Nouns on a Phone" is a multiplayer word-guessing game with three exciting rounds:

1. **Round 1: Describe the Word** - Describe the word to your team without saying the word itself
2. **Round 2: Act Out the Word** - Act out the word using gestures and body language  
3. **Round 3: One Word Only** - Describe the word using only one word

## Features

### Core Gameplay
- **Word Input Phase**: Add custom words to your game or use sample words for quick testing
- **Customizable Timer**: Choose from 10-120 seconds per team (with quick presets for 30s, 60s, 90s)
- **Team Scoring**: Track scores for two teams throughout all three rounds
- **Word Management**: Each word appears only once per round (unless time runs out)
- **Skip Functionality**: Optional skip button to pass on difficult words (skipped words return later in the round)
- **Smooth Transitions**: Beautiful animations between game phases
- **Final Results**: See which team wins and play again option

### Audio & Sound
- **Background Music**: Ambient background music during active gameplay
- **Sound Effects**: Timer alerts and game phase transitions
- **Audio Controls**: Toggle sound on/off with easy access during gameplay
- **Volume Management**: Separate controls for background music and sound effects

### Analytics & Statistics
- **Word Performance Tracking**: See which words were easiest/hardest to guess
- **Skip Analytics**: Track how many times each word was skipped
- **Time Analytics**: Average time spent on each word across all rounds
- **Performance Insights**: Color-coded statistics showing word difficulty
- **Post-Game Analysis**: Detailed statistics view after each game

### User Experience
- **Responsive Design**: Works on all iPhone sizes with adaptive layouts
- **Modern UI**: Clean, intuitive interface with smooth animations
- **Accessibility**: VoiceOver support and accessibility labels
- **Quick Setup**: Sample word generator for instant game start
- **Game Rules**: Built-in help and information screens

## How to Play

1. **Setup**: Configure timer duration and enable/disable skip functionality
2. **Word Input**: Add words to your game (minimum 3 words required) or use sample words
3. **Overview**: Review the three rounds and their rules
4. **Gameplay**: Teams take turns with customizable timer duration
5. **Scoring**: Tap "Correct!" when a word is guessed successfully, or "Skip" if needed
6. **Results**: See final scores, winner, and detailed word statistics

## Technical Details

- Built with SwiftUI for iOS
- Uses MVVM architecture with ObservableObject for state management
- Responsive design that works on all iPhone sizes
- Clean, modern UI with smooth animations
- Comprehensive test suite with unit tests for all game logic

## Files Structure

- `GameModels.swift` - Core game logic and state management
- `WordInputView.swift` - Word input interface with sample word generation
- `GameOverviewView.swift` - Game rules and round introduction
- `GamePlayView.swift` - Main gameplay interface with timer and scoring
- `RoundTransitionView.swift` - Team transition screens with sound settings access
- `GameOverView.swift` - Final results, winner display, and word statistics
- `ContentView.swift` - Main app coordinator
- `SampleWords.swift` - Helper for testing with sample words
- `SoundManager.swift` - Audio management and sound effects
- `SoundSettingsView.swift` - Audio configuration interface
- `WordStatisticsView.swift` - Analytics and performance tracking display
- `SetupView.swift` - Game configuration (timer, skip settings, audio)
- `GameDesignSystem.swift` - Reusable UI components and design system

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Getting Started

1. Open the project in Xcode
2. Select your target device or simulator
3. Build and run the app
4. Configure timer duration and game settings
5. Start by adding words or using sample words for testing
6. Enjoy playing with friends and family!

## Game Rules

- Each team gets a customizable amount of time per round (10-120 seconds)
- Words can only be used once per round (unless time expires)
- Teams alternate turns between rounds
- Skip functionality is optional and can be enabled/disabled in settings
- The team with the highest total score after all three rounds wins
- In case of a tie, both teams are celebrated as winners
- Detailed statistics are shown after each game for performance analysis

## Audio Setup

The app includes background music and sound effects. Audio files should be placed in the `Sounds` folder:
- `clock_tick_old.wav` - Background music during gameplay
- `2_gentle_pulse_high_pitch.wav` - Timer expiration alert

See `AUDIO_SETUP.md` for detailed audio configuration instructions. 