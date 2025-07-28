import XCTest
@testable import NounsOnAPhone

final class TimerManagerTests: XCTestCase {
    var timerManager: TimerManager!
    var mockDelegate: MockTimerManagerDelegate!
    
    override func setUp() {
        super.setUp()
        timerManager = TimerManager()
        mockDelegate = MockTimerManagerDelegate()
        timerManager.delegate = mockDelegate
    }
    
    override func tearDown() {
        timerManager.stopTimer()
        timerManager = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        XCTAssertEqual(timerManager.timeRemaining, 60, "Should start with 60 seconds remaining")
        XCTAssertEqual(timerManager.timerDuration, 60, "Should start with 60 second duration")
        XCTAssertFalse(timerManager.isTimerRunning, "Timer should not be running initially")
    }
    
    func testCustomInitialization() {
        let customTimerManager = TimerManager(duration: 90)
        XCTAssertEqual(customTimerManager.timeRemaining, 90, "Should start with custom duration remaining")
        XCTAssertEqual(customTimerManager.timerDuration, 90, "Should start with custom duration")
        XCTAssertFalse(customTimerManager.isTimerRunning, "Timer should not be running initially")
    }
    
    // MARK: - Timer Duration Tests
    
    func testUpdateTimerDuration() {
        timerManager.updateTimerDuration(45)
        
        XCTAssertEqual(timerManager.timerDuration, 45, "Duration should be updated to 45")
        XCTAssertEqual(timerManager.timeRemaining, 45, "Remaining time should be updated when timer not running")
    }
    
    func testUpdateTimerDurationWhileRunning() {
        timerManager.startTimer()
        let originalRemaining = timerManager.timeRemaining
        
        timerManager.updateTimerDuration(30)
        
        XCTAssertEqual(timerManager.timerDuration, 30, "Duration should be updated to 30")
        XCTAssertEqual(timerManager.timeRemaining, originalRemaining, "Remaining time should not change when timer is running")
        
        timerManager.stopTimer()
    }
    
    // MARK: - Timer Control Tests
    
    func testStartTimer() {
        timerManager.startTimer()
        
        XCTAssertTrue(timerManager.isTimerRunning, "Timer should be running after start")
        
        timerManager.stopTimer()
    }
    
    func testStopTimer() {
        timerManager.startTimer()
        XCTAssertTrue(timerManager.isTimerRunning, "Timer should be running")
        
        timerManager.stopTimer()
        XCTAssertFalse(timerManager.isTimerRunning, "Timer should not be running after stop")
    }
    
    func testResetTimer() {
        timerManager.updateTimerDuration(30)
        timerManager.startTimer()
        
        // Wait a moment for timer to tick
        let expectation = XCTestExpectation(description: "Timer tick")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        timerManager.resetTimer()
        
        XCTAssertFalse(timerManager.isTimerRunning, "Timer should not be running after reset")
        XCTAssertEqual(timerManager.timeRemaining, 30, "Remaining time should be reset to duration")
    }
    
    // MARK: - Timer Countdown Tests
    
    func testTimerCountdown() {
        timerManager.updateTimerDuration(3) // 3 seconds for quick test
        timerManager.startTimer()
        
        let initialTime = timerManager.timeRemaining
        
        // Wait for timer to tick down
        let expectation = XCTestExpectation(description: "Timer countdown")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertLessThan(timerManager.timeRemaining, initialTime, "Timer should count down")
        
        timerManager.stopTimer()
    }
    
    func testTimerExpiration() {
        timerManager.updateTimerDuration(1) // 1 second for quick test
        timerManager.startTimer()
        
        // Wait for timer to expire
        let expectation = XCTestExpectation(description: "Timer expiration")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)
        
        XCTAssertFalse(timerManager.isTimerRunning, "Timer should stop when expired")
        XCTAssertEqual(timerManager.timeRemaining, 0, "Time remaining should be 0 when expired")
        XCTAssertTrue(mockDelegate.timerDidExpireCalled, "Delegate should be notified of expiration")
    }
    
    // MARK: - Delegate Tests
    
    func testDelegateNotification() {
        timerManager.updateTimerDuration(1) // 1 second for quick test
        timerManager.startTimer()
        
        // Wait for timer to expire
        let expectation = XCTestExpectation(description: "Delegate notification")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)
        
        XCTAssertTrue(mockDelegate.timerDidExpireCalled, "Delegate should be called when timer expires")
        XCTAssertEqual(mockDelegate.timerDidExpireCallCount, 1, "Delegate should be called exactly once")
    }
    
    func testNoDelegateSet() {
        timerManager.delegate = nil
        timerManager.updateTimerDuration(1)
        timerManager.startTimer()
        
        // Wait for timer to expire - should not crash without delegate
        let expectation = XCTestExpectation(description: "Timer expiration without delegate")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)
        
        XCTAssertFalse(timerManager.isTimerRunning, "Timer should still stop when expired")
        XCTAssertEqual(timerManager.timeRemaining, 0, "Time remaining should be 0 when expired")
    }
    
    // MARK: - Edge Cases Tests
    
    func testZeroDuration() {
        timerManager.updateTimerDuration(0)
        timerManager.startTimer()
        
        // Should immediately expire
        let expectation = XCTestExpectation(description: "Immediate expiration")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertFalse(timerManager.isTimerRunning, "Timer should not be running with 0 duration")
        XCTAssertTrue(mockDelegate.timerDidExpireCalled, "Delegate should be called for immediate expiration")
    }
    
    func testNegativeDuration() {
        timerManager.updateTimerDuration(-10)
        
        XCTAssertEqual(timerManager.timerDuration, -10, "Should accept negative duration")
        XCTAssertEqual(timerManager.timeRemaining, -10, "Should set negative remaining time")
        
        timerManager.startTimer()
        
        // Should immediately expire with negative duration
        let expectation = XCTestExpectation(description: "Negative duration expiration")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(mockDelegate.timerDidExpireCalled, "Should expire immediately with negative duration")
    }
    
    func testLargeDuration() {
        let largeDuration = 3600 // 1 hour
        timerManager.updateTimerDuration(largeDuration)
        
        XCTAssertEqual(timerManager.timerDuration, largeDuration, "Should handle large durations")
        XCTAssertEqual(timerManager.timeRemaining, largeDuration, "Should set large remaining time")
    }
    
    // MARK: - Multiple Start/Stop Tests
    
    func testMultipleStartCalls() {
        timerManager.updateTimerDuration(5)
        
        timerManager.startTimer()
        XCTAssertTrue(timerManager.isTimerRunning, "Timer should be running after first start")
        
        timerManager.startTimer() // Second start call
        XCTAssertTrue(timerManager.isTimerRunning, "Timer should still be running after second start")
        
        timerManager.stopTimer()
    }
    
    func testMultipleStopCalls() {
        timerManager.startTimer()
        timerManager.stopTimer()
        XCTAssertFalse(timerManager.isTimerRunning, "Timer should not be running after first stop")
        
        timerManager.stopTimer() // Second stop call - should not crash
        XCTAssertFalse(timerManager.isTimerRunning, "Timer should still not be running after second stop")
    }
    
    // MARK: - Memory Management Tests
    
    func testDeinit() {
        var localTimerManager: TimerManager? = TimerManager()
        localTimerManager?.startTimer()
        
        XCTAssertTrue(localTimerManager?.isTimerRunning == true, "Timer should be running")
        
        // Timer should be cleaned up when deallocated
        localTimerManager = nil
        // If this doesn't crash, deinit properly cleaned up the timer
    }
    
    // MARK: - Sound Manager Integration Tests
    
    func testSoundManagerCall() {
        // This test verifies that the sound manager is called when timer expires
        // We can't easily mock SoundManager.shared, but we can verify the timer expires correctly
        timerManager.updateTimerDuration(1)
        timerManager.startTimer()
        
        let expectation = XCTestExpectation(description: "Sound manager integration")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)
        
        XCTAssertTrue(mockDelegate.timerDidExpireCalled, "Timer expiration should trigger all callbacks")
    }
}

// MARK: - Mock Delegate

class MockTimerManagerDelegate: TimerManagerDelegate {
    var timerDidExpireCalled = false
    var timerDidExpireCallCount = 0
    
    func timerDidExpire() {
        timerDidExpireCalled = true
        timerDidExpireCallCount += 1
    }
} 