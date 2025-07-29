# Performance Optimization Guide
## Fishbowl (Nouns on a Phone) iOS App

### Overview
This document outlines performance optimization strategies for the Fishbowl app's new manager-based architecture implemented in Phase 2.

---

## Current Architecture Performance Analysis

### ✅ **Improvements Achieved**
- **Reduced Memory Footprint**: GameState class reduced from 474 lines to ~170 lines (64% reduction)
- **Better Separation of Concerns**: 6 specialized managers vs. monolithic GameState
- **Improved Testability**: Each manager can be tested independently
- **Cleaner Dependencies**: Reduced coupling between UI and business logic

### 📊 **Performance Metrics to Monitor**
1. **Memory Usage**: Track memory allocation in managers
2. **UI Responsiveness**: Measure frame rate during gameplay
3. **State Update Frequency**: Monitor @Published property changes
4. **Timer Performance**: Ensure consistent 1-second intervals

---

## Performance Optimization Strategies

### 1. **@Published Property Optimization** 🚀

#### Current State
```swift
// Multiple @Published properties in each manager
@Published var team1Score: Int = 0
@Published var team2Score: Int = 0
@Published var currentWord: Word? = nil
@Published var timeRemaining: Int = 60
```

#### Optimization Opportunities
```swift
// Consider combining related properties
struct ScoreState {
    let team1Score: Int
    let team2Score: Int
    let teamTurnScores: (team1: [Int], team2: [Int])
}

class ScoreManager: ObservableObject {
    @Published var scoreState = ScoreState(team1Score: 0, team2Score: 0, teamTurnScores: ([], []))
    
    // Reduces number of published updates
    func updateScores(team1: Int, team2: Int) {
        scoreState = ScoreState(
            team1Score: team1,
            team2Score: team2,
            teamTurnScores: scoreState.teamTurnScores
        )
    }
}
```

**Benefits**: Reduces UI update frequency, batches related changes

### 2. **Timer Performance Optimization** ⏱️

#### Current Implementation
```swift
// TimerManager.swift
timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
    guard let self = self else { return }
    if self.timeRemaining > 0 {
        self.timeRemaining -= 1
    } else {
        self.timerExpired()
    }
}
```

#### Optimized Version
```swift
// Use DispatchSourceTimer for better performance
class TimerManager: ObservableObject {
    private var timer: DispatchSourceTimer?
    private let timerQueue = DispatchQueue(label: "timer.queue", qos: .userInteractive)
    
    func startTimer() {
        timer = DispatchSource.makeTimerSource(queue: timerQueue)
        timer?.schedule(deadline: .now(), repeating: .seconds(1))
        timer?.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                self?.updateTime()
            }
        }
        timer?.resume()
    }
    
    private func updateTime() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            timerExpired()
        }
    }
}
```

**Benefits**: More accurate timing, better battery life, reduced main thread blocking

### 3. **Analytics Performance** 📈

#### Current Implementation
```swift
// Heavy computation on main thread
func getWordStatistics(from words: [Word]) -> [GameState.WordStat] {
    var stats: [GameState.WordStat] = []
    for word in words {
        // Complex calculations...
    }
    return stats.sorted { $0.averageTime > $1.averageTime }
}
```

#### Optimized Version
```swift
class AnalyticsManager: ObservableObject {
    private let analyticsQueue = DispatchQueue(label: "analytics.queue", qos: .utility)
    
    func getWordStatistics(from words: [Word], completion: @escaping ([GameState.WordStat]) -> Void) {
        analyticsQueue.async { [weak self] in
            guard let self = self else { return }
            
            let stats = words.compactMap { word -> GameState.WordStat? in
                let skips = self.skipsByWord[word.id] ?? 0
                let totalTime = self.timeSpentByWord[word.id] ?? 0
                
                guard totalTime > 0 || skips > 0 else { return nil }
                
                return GameState.WordStat(
                    word: word,
                    skips: skips,
                    averageTime: Double(totalTime) / 3.0,
                    totalTime: totalTime
                )
            }.sorted { $0.averageTime > $1.averageTime }
            
            DispatchQueue.main.async {
                completion(stats)
            }
        }
    }
}
```

**Benefits**: Prevents UI blocking, improves responsiveness during analytics calculations

### 4. **Memory Management** 💾

#### Word Manager Optimization
```swift
class WordManager: ObservableObject {
    // Use lazy loading for large word lists
    private lazy var wordPool: [Word] = loadWords()
    
    // Implement word recycling to reduce allocations
    private var recycledWords: [Word] = []
    
    func getNextWord() -> Word? {
        if let recycled = recycledWords.popLast() {
            return recycled
        }
        return unusedWords.randomElement()
    }
    
    func recycleWord(_ word: Word) {
        recycledWords.append(word)
    }
}
```

#### Analytics Data Management
```swift
class AnalyticsManager: ObservableObject {
    // Use weak references to prevent memory leaks
    private weak var gameCoordinator: GameCoordinator?
    
    // Implement data pruning for long sessions
    func pruneOldData() {
        let cutoffDate = Date().addingTimeInterval(-3600) // 1 hour ago
        // Remove old analytics data to prevent memory growth
    }
}
```

### 5. **UI Rendering Optimization** 🎨

#### SwiftUI Performance Best Practices

```swift
// GamePlayView optimizations
struct GamePlayView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        // Use @State for local UI state to avoid unnecessary updates
        @State var animationScale: CGFloat = 1.0
        
        VStack {
            // Extract expensive views into separate components
            TimerDisplayView(timeRemaining: gameState.timerManager.timeRemaining)
            
            // Use equatable to prevent unnecessary redraws
            WordCardView(word: gameState.wordManager.currentWord)
                .equatable()
            
            // Cache score views
            ScoreRowView(
                team1Score: gameState.scoreManager.team1Score,
                team2Score: gameState.scoreManager.team2Score
            )
            .id("scores") // Stable identity for better performance
        }
    }
}

struct WordCardView: View, Equatable {
    let word: Word?
    
    static func == (lhs: WordCardView, rhs: WordCardView) -> Bool {
        lhs.word?.id == rhs.word?.id
    }
    
    var body: some View {
        // Optimized word display implementation
    }
}
```

---

## Performance Testing Strategy

### 1. **Instruments Profiling** 🔍

#### Memory Profiling
```bash
# Profile memory usage during gameplay
# Look for:
# - Memory leaks in manager instances
# - Excessive allocations during word changes
# - Analytics data growth over time
```

#### Time Profiler
```bash
# Profile CPU usage
# Focus on:
# - Timer callback performance
# - Analytics calculations
# - UI update cycles
# - Manager coordination overhead
```

### 2. **Automated Performance Tests**

```swift
// PerformanceTests.swift
import XCTest
@testable import NounsOnAPhone

class PerformanceTests: XCTestCase {
    
    func testScoreManagerPerformance() {
        let scoreManager = ScoreManager()
        
        measure {
            // Test 1000 score increments
            for _ in 0..<1000 {
                scoreManager.incrementScore(for: 1)
                scoreManager.incrementScore(for: 2)
            }
        }
    }
    
    func testAnalyticsCalculationPerformance() {
        let analytics = AnalyticsManager()
        let words = (0..<1000).map { Word(text: "word\($0)") }
        
        // Setup test data
        for word in words {
            analytics.recordWordSkip(wordId: word.id)
            analytics.recordWordTime(wordId: word.id, timeSpent: Int.random(in: 1...30))
        }
        
        measure {
            let _ = analytics.getWordStatistics(from: words)
        }
    }
    
    func testWordManagerSelectionPerformance() {
        let wordManager = WordManager()
        
        // Add many words
        for i in 0..<1000 {
            wordManager.addWord("word\(i)")
        }
        
        wordManager.setupForRound(usedWordIds: [])
        
        measure {
            // Test word selection performance
            for _ in 0..<100 {
                _ = wordManager.getNextWord()
            }
        }
    }
}
```

### 3. **Real-World Performance Monitoring**

#### Custom Performance Metrics
```swift
class PerformanceMonitor {
    static let shared = PerformanceMonitor()
    
    private var frameRateMonitor: CADisplayLink?
    private var memoryUsageTimer: Timer?
    
    func startMonitoring() {
        // Monitor frame rate
        frameRateMonitor = CADisplayLink(target: self, selector: #selector(trackFrameRate))
        frameRateMonitor?.add(to: .main, forMode: .default)
        
        // Monitor memory usage
        memoryUsageTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.logMemoryUsage()
        }
    }
    
    @objc private func trackFrameRate() {
        // Track FPS during gameplay
    }
    
    private func logMemoryUsage() {
        let usage = mach_task_basic_info()
        // Log memory statistics
    }
}
```

---

## Performance Benchmarks & Goals

### Target Performance Metrics

| Metric | Current | Target | Critical |
|--------|---------|--------|----------|
| App Launch Time | < 2s | < 1s | < 3s |
| Game Start Time | < 0.5s | < 0.3s | < 1s |
| Timer Accuracy | ±50ms | ±10ms | ±100ms |
| Memory Usage | < 50MB | < 30MB | < 100MB |
| Frame Rate | 60 FPS | 60 FPS | > 30 FPS |
| Analytics Calculation | < 200ms | < 100ms | < 500ms |

### Battery Life Optimization

1. **Reduce Timer Frequency**: Use adaptive timing based on game state
2. **Background Processing**: Move analytics to background queues
3. **Efficient Animations**: Use Core Animation instead of SwiftUI animations for complex sequences
4. **Network Optimization**: Batch analytics uploads (if implemented)

---

## Implementation Priority

### Phase 3.3.1: Critical Optimizations (Week 1)
- [ ] Implement DispatchSourceTimer for TimerManager
- [ ] Add async analytics processing
- [ ] Optimize @Published property usage in managers

### Phase 3.3.2: Advanced Optimizations (Week 2)  
- [ ] Implement memory recycling in WordManager
- [ ] Add performance monitoring infrastructure
- [ ] Create automated performance test suite

### Phase 3.3.3: Fine-tuning (Week 3)
- [ ] Profile with Instruments and optimize hotspots
- [ ] Implement lazy loading strategies
- [ ] Add performance dashboards

---

## Monitoring & Maintenance

### Continuous Performance Monitoring
1. **Automated Performance Tests**: Run with each CI build
2. **Memory Leak Detection**: Weekly Instruments sessions
3. **User Experience Metrics**: Track real-world performance data
4. **Performance Regression Detection**: Benchmark comparisons

### Performance Review Schedule
- **Weekly**: Review performance test results
- **Monthly**: Comprehensive profiling session
- **Quarterly**: Architecture performance review
- **Release**: Full performance validation

---

*Last Updated: 2025-01-27 - Phase 3 Performance Optimization Plan* 