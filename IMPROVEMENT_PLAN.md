# Fishbowl App - Code Improvement Plan

## Overview
This document outlines recommended improvements for the Fishbowl (Nouns on a Phone) iOS app based on code review conducted on 2025-07-14.

## Current App Strengths ✅
- **Clean Architecture**: Well-structured MVVM pattern with proper separation of concerns
- **Comprehensive Features**: Rich feature set including analytics, audio, skip functionality  
- **Responsive Design**: Excellent landscape/portrait layout handling
- **Design System**: Solid design tokens and reusable components in `GameDesignSystem.swift`
- **User Experience**: Thoughtful UX with animations, sound feedback, and accessibility considerations

## Critical Issues 🚨

### 1. GameState Class Complexity
**File**: `GameModels.swift` (Lines 71-530)
**Issue**: 530-line "God Class" that handles too many responsibilities
**Impact**: Hard to maintain, test, and debug

### 2. Missing Implementation
**File**: `WordInputView.swift:86`
**Issue**: Calls `gameState.addSampleWords(count: 5)` but method doesn't exist
**Impact**: Build error/runtime crash

### 3. Minimal Test Coverage
**File**: `NounsOnAPhoneTests.swift`
**Issue**: Only contains placeholder test
**Impact**: No safety net for refactoring, potential bugs

### 4. Words Per Minute Calculation Issues
**Files**: `GameModels.swift:493-529`, `WordsPerMinuteTable.swift`
**Issue**: WPM calculations are incorrect when teams move through multiple rounds in the same timer
**Impact**: Inaccurate analytics display, misleading performance metrics

**Root Cause**: The `roundStats` tracking logic has several flaws:
- Time is tracked per round, but when a team advances multiple rounds in one timer period, only the final round gets the time
- The calculation divides by 60 seconds but uses actual elapsed time, creating inconsistency
- `team1Time`/`team2Time` accumulate incorrectly across round transitions

### 5. Score Progression Chart Y-Axis Scaling
**Files**: `ScoreProgressionChart.swift:147-153`, `AxisLabels.swift:224-231`
**Issue**: Y-axis shows every score increment (1, 2, 3, 4...) making chart cluttered
**Impact**: Poor readability with many score points
**Request**: Label only every 5 points (0, 5, 10, 15...)

## Improvement Roadmap

## Phase 1: Critical Fixes (High Priority) 🔥

### 1.1 Implement Missing Sample Words Method
**Estimated Time**: 30 minutes
**Files**: `GameModels.swift`

```swift
extension GameState {
    func addSampleWords(count: Int = 5) {
        let samples = [
            "Pizza", "Elephant", "Basketball", "Sunshine", "Mountain",
            "Ocean", "Guitar", "Butterfly", "Rainbow", "Coffee",
            "Dragon", "Castle", "Lightning", "Telescope", "Waterfall"
        ]
        samples.prefix(count).forEach { addWord($0) }
    }
}
```

### 1.2 Remove Debug Code
**Estimated Time**: 1 hour
**Files**: `GameModels.swift`
**Action**: Remove or replace with proper logging

- Line 229: `print("[DEBUG] Timer expired for Team...")`
- Line 340: `print("[DEBUG] Game ending..."`
- Line 408: `print("[DEBUG] Reset scores..."`
- Line 475-482: All debug prints in `recordTeamTurnScore()`

### 1.3 Fix Audio Settings Coupling
**Estimated Time**: 30 minutes
**Files**: `SoundManager.swift:129`
**Current Issue**:
```swift
isSoundEffectsEnabled = isBackgroundMusicEnabled // Unintended coupling
```
**Fix**: Allow independent control of background music and sound effects

### 1.4 Fix Words Per Minute Calculation ✅ COMPLETED
**Estimated Time**: 2-3 hours
**Files**: `GameModels.swift`
**Priority**: High (affects core analytics)

**Problems Fixed**:
1. **Multi-round timer issue**: ✅ Now properly tracks time per team per round
2. **Time allocation**: ✅ Time is correctly allocated to each round based on actual time spent
3. **Inconsistent calculation**: ✅ WPM calculation remains accurate: `words_correct / (time_in_seconds / 60)`

**Solution Implemented**:
```swift
// Added proper per-team, per-round time tracking
private var teamRoundStartTimes: [Int: [RoundType: Date]] = [1: [:], 2: [:]]

// Time is recorded when:
// 1. Timer expires (team turn ends)
// 2. Round advances mid-timer 
// 3. Game ends naturally

private func recordTimeForCurrentRound() {
    guard !turnTimeAlreadyAdded else { return }
    
    if let roundStartTime = teamRoundStartTimes[currentTeam]?[currentRound] {
        let timeSpentInRound = Int(Date().timeIntervalSince(roundStartTime))
        
        if currentTeam == 1 {
            roundStats[currentRound]?.team1Time += timeSpentInRound
        } else {
            roundStats[currentRound]?.team2Time += timeSpentInRound
        }
        
        // Reset for next time recording
        teamRoundStartTimes[currentTeam]?[currentRound] = Date()
        turnTimeAlreadyAdded = true
    }
}
```

**Result**: WPM calculations now accurately reflect time spent with words showing per round!

### 1.5 Fix Chart Y-Axis Scaling
**Estimated Time**: 1 hour
**Files**: `ScoreProgressionChart.swift`
**Priority**: Medium (UX improvement)

**Current Issue**: Shows every score (1, 2, 3, 4...) making chart cluttered
**Fix**: Show only multiples of 5 (0, 5, 10, 15...)

```swift
// In AxisLabels struct, line 224
ForEach(stride(from: 0, through: maxScore, by: 5), id: \.self) { score in
    // ... existing label code
}

// In GridLines struct, line 147  
ForEach(stride(from: 0, through: maxScore, by: 5), id: \.self) { score in
    // ... existing grid line code
}
```

## Phase 2: Architecture Refactoring (High Priority) 🏗️

### 2.1 Split GameState Into Focused Managers
**Estimated Time**: 8-12 hours
**Goal**: Break down the 530-line GameState class

**New Architecture**:
```swift
// Core game coordination
class GameState: ObservableObject {
    @Published var currentPhase: GamePhase = .setup
    @Published var words: [Word] = []
    // Delegate to specialized managers
}

// Timer-specific logic
class TimerManager: ObservableObject {
    @Published var timeRemaining: Int = 60
    @Published var timerDuration: Int = 60
    @Published var isTimerRunning: Bool = false
    // All timer-related methods
}

// Score tracking and analytics
class ScoreManager: ObservableObject {
    @Published var team1Score: Int = 0
    @Published var team2Score: Int = 0
    @Published var team1TurnScores: [Int] = [0]
    @Published var team2TurnScores: [Int] = [0]
    // All scoring methods
}

// Round and turn management
class RoundManager: ObservableObject {
    @Published var currentRound: RoundType = .describe
    @Published var currentTeam: Int = 1
    @Published var currentWord: Word?
    // Round transition logic
}

// Statistics and analytics
class AnalyticsManager: ObservableObject {
    @Published var skipsByWord: [UUID: Int] = [:]
    @Published var timeSpentByWord: [UUID: Int] = [:]
    @Published var roundStats: [RoundType: RoundStats] = [:]
    // Analytics calculations
}
```

### 2.2 Create Manager Protocols
**Estimated Time**: 2-3 hours

```swift
protocol TimerManagerProtocol {
    func startTimer()
    func stopTimer()
    func timerExpired()
}

protocol ScoreManagerProtocol {
    func incrementScore(for team: Int)
    func resetScores()
    func getWinner() -> Int?
}
```

## Phase 3: Testing Infrastructure (High Priority) 🧪

### 3.1 Add Unit Tests for Game Logic
**Estimated Time**: 6-8 hours
**Files**: Create comprehensive test suite

**Test Categories**:
- Game flow tests (setup → word input → playing → game over)
- Timer functionality tests
- Score calculation tests  
- Word statistics tests
- Round transition tests
- Skip functionality tests

**Example Test Structure**:
```swift
struct GameStateTests {
    @Test func testWordGuessedIncrementsScore() {
        let gameState = GameState()
        gameState.team1Score = 0
        gameState.currentTeam = 1
        
        gameState.wordGuessed()
        
        #expect(gameState.team1Score == 1)
    }
    
    @Test func testTimerExpirationSwitchesTeams() {
        // Test timer expiration logic
    }
    
    @Test func testRoundProgression() {
        // Test round advancement logic
    }
}
```

### 3.2 Add Integration Tests
**Estimated Time**: 4-5 hours
- Full game flow integration tests
- Audio integration tests
- UI interaction tests

## Phase 4: Code Quality & Performance (Medium Priority) 🔧

### 4.1 Extract Constants
**Estimated Time**: 2 hours
**Create**: `GameConstants.swift`

```swift
struct GameConstants {
    static let minimumWordsToStart = 3
    static let defaultTimerDuration = 60
    static let timerWarningThreshold = 0.5  // 50% of time remaining
    static let timerDangerThreshold = 0.17   // 17% of time remaining
    static let defaultBackgroundVolume: Float = 0.3
    static let defaultEffectsVolume: Float = 0.7
}
```

### 4.2 Improve Error Handling
**Estimated Time**: 3-4 hours
- Add proper error types
- Handle audio file loading failures gracefully
- Add user-facing error messages

### 4.3 Performance Optimizations
**Estimated Time**: 3-4 hours
- Implement lazy loading for statistics calculations
- Optimize state updates to reduce UI redraws
- Add word caching for better performance

## Phase 5: Enhanced Features (Low Priority) ✨

### 5.1 Advanced Analytics
**Estimated Time**: 4-6 hours
- Word difficulty scoring based on skip rates and time
- Team performance comparisons
- Historical game data

### 5.2 Data Persistence
**Estimated Time**: 6-8 hours
- Save game sessions using Core Data or UserDefaults
- Resume interrupted games
- Game history tracking

### 5.3 Enhanced Audio
**Estimated Time**: 3-4 hours
- Audio ducking for background music
- More sound effects for different game events
- Haptic feedback integration

### 5.4 Import/Export Features
**Estimated Time**: 4-5 hours
- Word list import from text files
- Export game statistics
- Share functionality for word lists

## Implementation Order Recommendation

### Week 1: Critical Fixes
1. Implement `addSampleWords()` method (30 min)
2. Remove debug print statements (1 hour)
3. Fix audio settings coupling (30 min)
4. Fix Words Per Minute calculation (2-3 hours)
5. Fix chart Y-axis scaling (1 hour)
6. Basic unit tests for core functionality (2-3 hours)

### Week 2-3: Architecture Refactoring
1. Create manager protocols
2. Split GameState into focused managers
3. Update UI to use new architecture
4. Comprehensive testing

### Week 4: Polish & Enhancement
1. Extract constants
2. Improve error handling
3. Performance optimizations
4. Enhanced features (optional)

## Success Metrics
- [ ] Build succeeds without errors
- [ ] Test coverage > 80%
- [ ] No classes > 200 lines
- [ ] All magic numbers extracted to constants
- [ ] No debug code in production
- [ ] Proper error handling throughout
- [ ] Words Per Minute calculations are accurate across multi-round turns
- [ ] Chart Y-axis shows appropriate scale (multiples of 5)
- [ ] Score progression correctly tracks cumulative scores at turn end

## Notes
- Backup current code before starting refactoring
- Consider creating feature branches for each major change
- Test thoroughly on different device sizes
- Consider adding SwiftLint for code style consistency

## Detailed Analysis: WPM Calculation Issue

### Current Implementation Problem
The WPM calculation issue occurs because:

1. **GameModels.swift:163** - Round stats are initialized only once per round
2. **GameModels.swift:222-225** - Time is added to `roundStats[currentRound]?.team1Time` based on the CURRENT round
3. **When advancing rounds mid-timer**: If a team finishes Round 1 and starts Round 2 in the same timer period, ALL the time gets attributed to Round 2

### Example Scenario That Breaks:
```
Timer starts (60 seconds) - Team 1, Round 1
- 30 seconds: Complete Round 1, advance to Round 2  
- 30 seconds: Timer expires in Round 2
Result: Round 1 gets 0 seconds, Round 2 gets 60 seconds (WRONG)
```

### Chart Y-Axis Issue
**Current Code**: `ScoreProgressionChart.swift:147`
```swift
ForEach(0...maxScore, id: \.self) { score in
```
Shows: 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12...

**Should be**:
```swift
ForEach(stride(from: 0, through: maxScore, by: 5), id: \.self) { score in
```
Shows: 0, 5, 10, 15, 20...

### Turn Score Tracking Verification
The `team1TurnScores` and `team2TurnScores` tracking appears correct:
- **GameModels.swift:474-483** - `recordTeamTurnScore()` correctly appends cumulative scores
- **GameModels.swift:230** - Called when timer expires (turn ends)
- **GameModels.swift:341** - Called when game ends naturally

The logic properly saves cumulative scores at the end of each timer period, which matches the requirement.

---
*Generated: 2025-07-14 by Claude Code Review*
*Updated: 2025-07-14 with specific WPM and Chart fixes*