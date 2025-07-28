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

## 🚨 To-Do: App Store Readiness

### Phase 1: Critical Fixes (HIGH PRIORITY - Must Fix Before Submission)

#### 🔥 **Critical Bugs**
- [ ] **Fix Missing Implementation**: `WordInputView.swift:86` calls `gameState.addSampleWords(count: 5)` but method doesn't exist
  - **File**: `GameModels.swift`
  - **Impact**: Runtime crash
  - **Fix**: Implement the missing method
- [ ] **Remove Debug Code**: Remove all `print("[DEBUG]...")` statements from production code
  - **Files**: `GameModels.swift` (lines 229, 340, 408, 475-482)
  - **Impact**: Professional code quality
- [ ] **Fix Audio Settings Coupling**: Background music and sound effects are unnecessarily linked
  - **File**: `SoundManager.swift:129`
  - **Fix**: Allow independent control of background music and sound effects

#### 📱 **App Store Requirements**
- [ ] **Update Bundle Identifier**: Change from `com.example.Fishbowl-v2` to unique identifier
  - **File**: Project settings
  - **Impact**: App Store submission requirement
- [ ] **App Store Connect Setup**: Create account and configure app metadata
  - [ ] App description and keywords
  - [ ] Screenshots for all device sizes
  - [ ] App icon in all required sizes
  - [ ] Privacy policy URL
- [ ] **Launch Screen**: Currently empty, needs proper design
  - **File**: `Info.plist` - `UILaunchScreen`
- [ ] **Code Signing**: Set up proper distribution certificate
  - **Impact**: Required for App Store distribution

### Phase 2: Code Quality & Bug Fixes (MEDIUM PRIORITY)

#### 🐛 **Analytics & Display Issues**
- [ ] **Fix Words Per Minute Calculation**: Incorrect when teams advance through multiple rounds
  - **Files**: `GameModels.swift:493-529`, `WordsPerMinuteTable.swift`
  - **Issue**: Time allocation bugs in multi-round scenarios
- [ ] **Fix Chart Y-Axis Scaling**: Shows every score increment (1,2,3,4...) making charts cluttered
  - **Files**: `ScoreProgressionChart.swift:147-153`
  - **Fix**: Show only multiples of 5 (0, 5, 10, 15...)
- [ ] **Score Tracking Edge Cases**: Some issues in turn score recording
  - **File**: `GameModels.swift`
  - **Impact**: Inaccurate analytics

#### 🏗️ **Architecture Improvements**
- [ ] **Refactor GameState Class**: Currently 553 lines - violates single responsibility principle
  - **File**: `GameModels.swift`
  - **Goal**: Split into focused managers (TimerManager, ScoreManager, RoundManager, AnalyticsManager)
- [ ] **Extract Constants**: Remove magic numbers throughout codebase
  - **Create**: `GameConstants.swift`
  - **Examples**: `minimumWordsToStart = 3`, `defaultTimerDuration = 60`
- [ ] **Improve Error Handling**: Add graceful handling of failures
  - **Files**: `SoundManager.swift` (audio file loading)
  - **Add**: User-facing error messages

### Phase 3: Testing & Quality Assurance (MEDIUM PRIORITY)

#### 🧪 **Testing Infrastructure**
- [ ] **Expand Unit Tests**: Currently minimal test coverage
  - **Files**: `NounsOnAPhoneTests/`
  - **Add**: Game flow tests, timer tests, score calculation tests
- [ ] **Integration Tests**: Full game flow and UI interaction tests
- [ ] **Performance Tests**: Memory usage and responsiveness testing

#### 🔧 **Code Quality**
- [ ] **Add SwiftLint**: For code style consistency
- [ ] **Documentation**: Add comprehensive code comments
- [ ] **Performance Optimization**: Reduce UI redraws and optimize state updates

### Phase 4: Enhanced Features (LOW PRIORITY)

#### ✨ **User Experience Improvements**
- [ ] **Haptic Feedback**: Add tactile feedback for game events
- [ ] **Advanced Analytics**: Word difficulty scoring, team performance comparisons
- [ ] **Data Persistence**: Save game sessions and history
- [ ] **Import/Export**: Word list import from text files, export statistics
- [ ] **Share Functionality**: Share word lists and game results

#### 🎵 **Audio Enhancements**
- [ ] **Audio Ducking**: Background music ducks during sound effects
- [ ] **More Sound Effects**: Different sounds for different game events
- [ ] **Volume Sliders**: Individual volume controls for music and effects

### Phase 5: Final Polish (LOW PRIORITY)

#### 🎨 **UI/UX Polish**
- [ ] **Animation Refinements**: Smoother transitions and micro-interactions
- [ ] **Accessibility Improvements**: Enhanced VoiceOver support
- [ ] **Dark Mode Support**: Full dark mode implementation
- [ ] **iPad Support**: Optimize for larger screens

#### 📊 **Analytics & Insights**
- [ ] **Game History**: Track and display historical game data
- [ ] **Performance Metrics**: Detailed team and word performance analysis
- [ ] **Export Features**: Share statistics and game results

---

## 📋 **Success Metrics**

- [ ] Build succeeds without errors
- [ ] Test coverage > 80%
- [ ] No classes > 200 lines
- [ ] All magic numbers extracted to constants
- [ ] No debug code in production
- [ ] Proper error handling throughout
- [ ] Words Per Minute calculations are accurate across multi-round turns
- [ ] Chart Y-axis shows appropriate scale (multiples of 5)
- [ ] Score progression correctly tracks cumulative scores at turn end
- [ ] App Store submission approved

## ⏱️ **Estimated Timeline**

- **Phase 1 (Critical Fixes)**: 1-2 days
- **Phase 2 (Code Quality)**: 3-5 days  
- **Phase 3 (Testing)**: 2-3 days
- **Phase 4 (Enhanced Features)**: 1-2 weeks (optional)
- **Phase 5 (Final Polish)**: 1-2 days

**Total to App Store Ready**: 1-2 weeks (focusing on Phases 1-3)

---

*Last Updated: 2025-07-17* 