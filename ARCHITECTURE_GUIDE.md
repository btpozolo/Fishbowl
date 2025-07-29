# Architecture Guide
## Fishbowl (Nouns on a Phone) iOS App

### Overview
This document provides comprehensive documentation for the Fishbowl app's manager-based architecture, implemented as part of Phase 2 refactoring.

---

## Architecture Overview

### 🏗️ **Manager-Based Architecture**
The app follows a clean separation of concerns using specialized manager classes coordinated by a central `GameCoordinator`.

```
┌─────────────────────────────────────────────────────┐
│                    UI Layer                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │ GamePlayView│  │ SetupView   │  │ GameOverView│  │
│  └─────────────┘  └─────────────┘  └─────────────┘  │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│                 GameState (Facade)                  │
│               Delegates to GameCoordinator          │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│              GameCoordinator                        │
│            (Central Coordination)                   │
└─┬─────────┬─────────┬─────────┬─────────┬───────────┘
  │         │         │         │         │
  ▼         ▼         ▼         ▼         ▼
┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐ ┌───────────┐
│ Timer │ │ Score │ │ Round │ │ Word  │ │ Analytics │
│Manager│ │Manager│ │Manager│ │Manager│ │ Manager   │
└───────┘ └───────┘ └───────┘ └───────┘ └───────────┘
```

---

## Core Components

### 1. **GameCoordinator** 🎮
**Purpose**: Central coordinator that orchestrates game flow and manager interactions

#### Key Responsibilities
- **Phase Management**: Controls game state transitions
- **Manager Coordination**: Delegates operations to appropriate managers
- **Event Handling**: Processes timer expiration, word events, etc.
- **Business Logic**: Implements high-level game rules

#### Interface
```swift
protocol GameCoordinatorProtocol: ObservableObject {
    // Published properties for UI binding
    var currentPhase: GamePhase { get }
    
    // Manager access
    var timerManager: TimerManager { get }
    var scoreManager: ScoreManager { get }
    var roundManager: RoundManager { get }
    var wordManager: WordManager { get }
    var analyticsManager: AnalyticsManager { get }
    
    // Phase management
    func proceedToWordInput()
    func goToSetupView()
    func startGame()
    func beginRound()
    func beginNextTurn()
    
    // Game actions
    func wordGuessed()
    func skipCurrentWord()
    func advanceTeamOrRound(wordsExhausted: Bool)
    
    // Word management
    func addWord(_ wordText: String)
    func canStartGame() -> Bool
}
```

#### Usage Example
```swift
let coordinator = GameCoordinator()

// Start a new game
coordinator.addWord("pizza")
coordinator.addWord("burger") 
coordinator.addWord("taco")
coordinator.startGame()
coordinator.beginRound()

// Handle game events
coordinator.wordGuessed()
coordinator.skipCurrentWord()
```

### 2. **TimerManager** ⏱️
**Purpose**: Manages game timer functionality with precise timing control

#### Key Features
- **Accurate Timing**: 1-second interval timer with drift correction
- **State Management**: Timer duration, remaining time, running state
- **Event Delegation**: Notifies coordinator of timer expiration
- **Sound Integration**: Triggers audio feedback on timer events

#### Interface
```swift
protocol TimerManagerProtocol: ObservableObject {
    var timeRemaining: Int { get }
    var timerDuration: Int { get set }
    var isTimerRunning: Bool { get }
    
    func startTimer()
    func stopTimer()
    func updateTimerDuration(_ duration: Int)
    func resetTimer()
}
```

#### Implementation Details
```swift
class TimerManager: ObservableObject, TimerManagerProtocol {
    @Published var timeRemaining: Int = 60
    @Published var timerDuration: Int = 60
    @Published var isTimerRunning: Bool = false
    
    private var timer: Timer?
    weak var delegate: TimerManagerDelegate?
    
    func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    private func tick() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            timerExpired()
        }
    }
}
```

### 3. **ScoreManager** 🏆
**Purpose**: Handles all scoring logic and turn tracking

#### Key Features
- **Team Scoring**: Independent score tracking for two teams
- **Turn History**: Complete score progression tracking
- **Winner Determination**: Automated winner calculation
- **Score Analytics**: Support for score-based analytics

#### Interface
```swift
protocol ScoreManagerProtocol: ObservableObject {
    var team1Score: Int { get }
    var team2Score: Int { get }
    var team1TurnScores: [Int] { get }
    var team2TurnScores: [Int] { get }
    
    func incrementScore(for team: Int)
    func resetScores()
    func getWinner() -> Int?
    func recordTeamTurnScore(for team: Int, score: Int)
}
```

#### Usage Patterns
```swift
// Increment score
scoreManager.incrementScore(for: 1) // Team 1 scores

// Track turn progression
scoreManager.recordTeamTurnScore(for: 1, score: scoreManager.team1Score)

// Determine winner
if let winner = scoreManager.getWinner() {
    print("Team \(winner) wins!")
}
```

### 4. **RoundManager** 🔄
**Purpose**: Manages game rounds, team turns, and word usage tracking

#### Key Features
- **Round Progression**: Manages three game rounds (Describe, Act Out, One Word)
- **Team Management**: Handles team switching and current team tracking
- **Word Usage Tracking**: Prevents word reuse within rounds
- **Transition Logic**: Determines when to advance rounds or switch teams

#### Interface
```swift
protocol RoundManagerProtocol: ObservableObject {
    var currentRound: RoundType { get }
    var currentTeam: Int { get }
    var lastTransitionReason: TransitionReason? { get }
    
    func advanceRound()
    func switchTeam()
    func resetToFirstRound()
    func markWordUsedInRound(_ wordId: UUID)
    func isWordUsedInRound(_ wordId: UUID) -> Bool
}
```

#### Round Flow Example
```swift
// Start with Describe round, Team 1
roundManager.currentRound == .describe
roundManager.currentTeam == 1

// Play words, then switch teams
roundManager.switchTeam()
roundManager.currentTeam == 2

// When all words used, advance round
roundManager.advanceRound()
roundManager.currentRound == .actOut
roundManager.currentTeam == 1 // Reset to team 1
```

### 5. **WordManager** 📝
**Purpose**: Manages word storage, selection, and game-specific word operations

#### Key Features
- **Word Storage**: Dynamic word list management
- **Random Selection**: Fair word selection algorithm
- **Skip Functionality**: Word skipping with validation
- **Round Setup**: Word filtering based on previous usage
- **Validation**: Duplicate detection and length limits

#### Interface
```swift
protocol WordManagerProtocol: ObservableObject {
    var words: [Word] { get }
    var currentWord: Word? { get }
    var skipEnabled: Bool { get }
    
    func addWord(_ text: String)
    func getNextWord() -> Word?
    func skipCurrentWord()
    func canStartGame() -> Bool
    func resetWords()
    func markCurrentWordGuessed()
    func hasUnusedWords() -> Bool
}
```

#### Word Lifecycle
```swift
// Setup
wordManager.addWord("pizza")
wordManager.setupForRound(usedWordIds: [])

// Gameplay
let word = wordManager.getNextWord()
// Player guesses correctly
wordManager.markCurrentWordGuessed()

// Or player skips
wordManager.skipCurrentWord()
```

### 6. **AnalyticsManager** 📊
**Purpose**: Comprehensive analytics and statistics tracking

#### Key Features
- **Word Analytics**: Skip counts, time spent per word
- **Performance Metrics**: Words per minute calculations
- **Round Statistics**: Team performance per round
- **Time Tracking**: Precise time allocation per team/round
- **Data Export**: Statistics generation for UI display

#### Interface
```swift
protocol AnalyticsManagerProtocol: ObservableObject {
    var skipsByWord: [UUID: Int] { get }
    var timeSpentByWord: [UUID: Int] { get }
    var roundStats: [RoundType: (team1Time: Int, team2Time: Int, team1Correct: Int, team2Correct: Int)] { get }
    
    func recordWordSkip(wordId: UUID)
    func recordWordTime(wordId: UUID, timeSpent: Int)
    func recordCorrectGuess(for team: Int, in round: RoundType)
    func getWordStatistics(from words: [Word]) -> [GameState.WordStat]
    func getWordsPerMinuteData() -> [GameState.WordsPerMinuteData]
}
```

#### Analytics Features
```swift
// Record events
analyticsManager.recordWordSkip(wordId: word.id)
analyticsManager.recordWordTime(wordId: word.id, timeSpent: 5)
analyticsManager.recordCorrectGuess(for: 1, in: .describe)

// Generate reports
let wordStats = analyticsManager.getWordStatistics(from: words)
let wpmData = analyticsManager.getWordsPerMinuteData()
```

---

## Manager Coordination Patterns

### 1. **Delegate Pattern** 🔗
Managers communicate with the coordinator through delegate protocols.

```swift
// TimerManager notifies coordinator of expiration
protocol TimerManagerDelegate: AnyObject {
    func timerDidExpire()
}

// WordManager notifies coordinator of events
protocol WordManagerDelegate: AnyObject {
    func wordManager(_ manager: WordManager, didSkipWord wordId: UUID)
    func wordManager(_ manager: WordManager, didSpendTime timeSpent: Int, onWord wordId: UUID)
}
```

### 2. **Event Flow Examples**

#### Word Guessed Flow
```swift
func wordGuessed() {
    guard let currentWord = wordManager.currentWord else { return }
    
    // 1. Record analytics
    analyticsManager.recordCorrectGuess(for: roundManager.currentTeam, in: roundManager.currentRound)
    
    // 2. Update word state
    wordManager.markCurrentWordGuessed()
    roundManager.markWordUsedInRound(currentWord.id)
    
    // 3. Update score
    scoreManager.incrementScore(for: roundManager.currentTeam)
    
    // 4. Check game progression
    if !wordManager.hasUnusedWords() {
        handleWordsExhausted()
    } else {
        _ = wordManager.getNextWord()
    }
}
```

#### Timer Expiration Flow
```swift
func timerDidExpire() {
    // 1. Record time for analytics
    analyticsManager.recordTimeForCurrentRound(team: roundManager.currentTeam, round: roundManager.currentRound)
    
    // 2. Record team turn score
    scoreManager.recordTeamTurnScore(for: roundManager.currentTeam, score: scoreManager.getCurrentScore(for: roundManager.currentTeam))
    
    // 3. Determine next action
    if wordManager.hasUnusedWords() {
        roundManager.switchTeam()
        currentPhase = .roundTransition
    } else {
        handleWordsExhausted()
    }
}
```

---

## Data Flow Architecture

### 1. **State Management** 📊
```swift
// UI observes GameState facade
@ObservedObject var gameState: GameState

// GameState delegates to GameCoordinator
private let gameCoordinator = GameCoordinator()

// UI accesses manager state through facade
Text("\(gameState.scoreManager.team1Score)")
Text("\(gameState.timerManager.timeRemaining)")
```

### 2. **Action Flow** ⚡
```
UI Action → GameState Method → GameCoordinator Method → Manager Methods → State Update → UI Update
```

Example:
```
Button("Correct!") → gameState.wordGuessed() → coordinator.wordGuessed() → 
scoreManager.incrementScore() + wordManager.markCurrentWordGuessed() → 
@Published updates → UI refresh
```

### 3. **Manager Dependencies** 🔗
```swift
// GameCoordinator orchestrates dependencies
private func setupRound() {
    // RoundManager provides word filtering
    let usedWordIds = roundManager.getAllUsedWordIds()
    
    // WordManager sets up available words
    wordManager.setupForRound(usedWordIds: usedWordIds)
    
    // AnalyticsManager initializes tracking
    analyticsManager.initializeRoundStats(for: roundManager.currentRound)
    analyticsManager.recordRoundStartTime(for: roundManager.currentTeam, round: roundManager.currentRound)
}
```

---

## Testing Strategy

### 1. **Unit Testing** 🧪
Each manager is independently testable:

```swift
func testScoreManagerIncrement() {
    let scoreManager = ScoreManager()
    
    scoreManager.incrementScore(for: 1)
    #expect(scoreManager.team1Score == 1)
    #expect(scoreManager.team2Score == 0)
}

func testTimerManagerExpiration() {
    let timerManager = TimerManager()
    let delegate = MockTimerDelegate()
    timerManager.delegate = delegate
    
    timerManager.timeRemaining = 1
    timerManager.startTimer()
    
    // Simulate expiration
    // Verify delegate called
}
```

### 2. **Integration Testing** 🔧
GameCoordinator tests verify manager coordination:

```swift
func testWordGuessedFlow() {
    let coordinator = GameCoordinator()
    coordinator.addWord("test")
    coordinator.beginRound()
    
    let initialScore = coordinator.scoreManager.team1Score
    coordinator.wordGuessed()
    
    #expect(coordinator.scoreManager.team1Score == initialScore + 1)
    #expect(coordinator.analyticsManager.roundStats[.describe]?.team1Correct == 1)
}
```

### 3. **Mock Objects** 🎭
```swift
class MockTimerManagerDelegate: TimerManagerDelegate {
    var timerExpiredCalled = false
    
    func timerDidExpire() {
        timerExpiredCalled = true
    }
}
```

---

## Performance Considerations

### 1. **@Published Property Optimization**
- Minimize the number of @Published properties
- Batch related updates when possible
- Use computed properties for derived state

### 2. **Memory Management**
- Weak delegate references to prevent retain cycles
- Efficient data structures for analytics
- Proper cleanup in manager reset methods

### 3. **Background Processing**
- Move analytics calculations to background queues
- Use DispatchSourceTimer for precise timing
- Implement lazy loading for expensive operations

---

## Migration Guide

### From Old Architecture
```swift
// OLD: Monolithic GameState
class GameState {
    @Published var team1Score: Int = 0
    @Published var currentRound: RoundType = .describe
    @Published var timeRemaining: Int = 60
    
    func wordGuessed() {
        // 50+ lines of mixed logic
    }
}

// NEW: Manager-based Architecture
class GameCoordinator {
    let scoreManager = ScoreManager()
    let roundManager = RoundManager() 
    let timerManager = TimerManager()
    
    func wordGuessed() {
        // Coordinated manager calls
        scoreManager.incrementScore(for: roundManager.currentTeam)
        analyticsManager.recordCorrectGuess(for: roundManager.currentTeam, in: roundManager.currentRound)
        // ... clear, focused logic
    }
}
```

### UI Migration
```swift
// OLD: Direct property access
Text("\(gameState.team1Score)")

// NEW: Manager property access (backward compatible)
Text("\(gameState.scoreManager.team1Score)")
```

---

## Best Practices

### 1. **Manager Design** 🎯
- **Single Responsibility**: Each manager handles one domain
- **Clear Interfaces**: Use protocols for manager contracts
- **Immutable State**: Prefer value types for data structures
- **Event-Driven**: Use delegates for cross-manager communication

### 2. **Error Handling** ⚠️
```swift
class WordManager: ObservableObject {
    func validateAndAddWord(_ text: String) -> WordValidationResult {
        guard !text.isEmpty else { return .empty }
        guard !isDuplicateWord(text) else { return .duplicate }
        guard isValidWordLength(text) else { return .tooLong }
        
        addWord(text)
        return .success
    }
}
```

### 3. **Logging and Debugging** 🐛
```swift
#if DEBUG
private func logManagerState() {
    print("ScoreManager: Team1=\(scoreManager.team1Score), Team2=\(scoreManager.team2Score)")
    print("RoundManager: Round=\(roundManager.currentRound), Team=\(roundManager.currentTeam)")
    print("TimerManager: Remaining=\(timerManager.timeRemaining), Running=\(timerManager.isTimerRunning)")
}
#endif
```

---

## Architecture Decision Records (ADRs)

### ADR-001: Manager-Based Architecture
**Status**: Accepted  
**Date**: 2025-01-27

**Context**: GameState class grew to 474 lines with mixed responsibilities

**Decision**: Split into specialized managers coordinated by GameCoordinator

**Consequences**:
- ✅ Improved testability and maintainability
- ✅ Clear separation of concerns
- ✅ Better code organization
- ❌ Slightly more complex initial setup
- ❌ More files to manage

### ADR-002: Facade Pattern for Backward Compatibility
**Status**: Accepted  
**Date**: 2025-01-27

**Context**: Existing UI code depends on GameState interface

**Decision**: Keep GameState as facade that delegates to GameCoordinator

**Consequences**:
- ✅ No UI changes required
- ✅ Gradual migration possible
- ✅ Maintains existing API
- ❌ Additional indirection layer

### ADR-003: Delegate Pattern for Manager Communication
**Status**: Accepted  
**Date**: 2025-01-27

**Context**: Managers need to communicate events to coordinator

**Decision**: Use delegate protocols instead of direct references

**Consequences**:
- ✅ Loose coupling between managers
- ✅ Clear event interfaces
- ✅ Testable with mock delegates
- ❌ More boilerplate code

---

## Future Enhancements

### Phase 4: Enhanced Features
- **HapticManager**: Tactile feedback coordination
- **SoundManager Integration**: Enhanced audio event coordination
- **DataPersistenceManager**: Game history and settings persistence
- **NetworkManager**: Multiplayer and cloud sync capabilities

### Phase 5: Advanced Analytics
- **MachineLearningManager**: Word difficulty prediction
- **ExportManager**: Advanced data export capabilities
- **InsightsManager**: Predictive analytics and recommendations

---

*Last Updated: 2025-01-27 - Manager Architecture Documentation* 