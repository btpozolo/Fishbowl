import Foundation

// MARK: - Round Manager Protocol
protocol RoundManagerProtocol: ObservableObject {
    var currentRound: RoundType { get }
    var currentTeam: Int { get }
    var lastTransitionReason: TransitionReason? { get }
    
    func advanceRound()
    func switchTeam()
    func resetToFirstRound()
    func markWordUsedInRound(_ wordId: UUID)
    func isWordUsedInRound(_ wordId: UUID) -> Bool
    func getAllUsedWordIds() -> Set<UUID>
    func hasUsedAllWords(totalWords: Int) -> Bool
    func canAdvanceRound(wordsUsed: Int, totalWords: Int) -> Bool
}

// MARK: - Round Manager Implementation
class RoundManager: ObservableObject, RoundManagerProtocol {
    @Published var currentRound: RoundType = .describe
    @Published var currentTeam: Int = 1
    @Published var lastTransitionReason: TransitionReason? = nil
    
    private var roundUsedWordIds: Set<UUID> = []
    
    func advanceRound() {
        switch currentRound {
        case .describe:
            currentRound = .actOut
        case .actOut:
            currentRound = .oneWord
        case .oneWord:
            break // Game should end
        }
        roundUsedWordIds.removeAll()
        lastTransitionReason = .wordsExhausted
    }
    
    func switchTeam() {
        currentTeam = currentTeam == 1 ? 2 : 1
        lastTransitionReason = .timerExpired
    }
    
    func resetToFirstRound() {
        currentRound = .describe
        currentTeam = 1
        roundUsedWordIds.removeAll()
        lastTransitionReason = nil
    }
    
    func markWordUsedInRound(_ wordId: UUID) {
        roundUsedWordIds.insert(wordId)
    }
    
    func isWordUsedInRound(_ wordId: UUID) -> Bool {
        return roundUsedWordIds.contains(wordId)
    }
    
    func getAllUsedWordIds() -> Set<UUID> {
        return roundUsedWordIds
    }
    
    func hasUsedAllWords(totalWords: Int) -> Bool {
        return roundUsedWordIds.count >= totalWords
    }
    
    func canAdvanceRound(wordsUsed: Int, totalWords: Int) -> Bool {
        // Can advance if not in final round and all words have been used
        return currentRound != .oneWord && wordsUsed >= totalWords
    }
    
    // MARK: - Convenience Methods
    
    func isFirstRound() -> Bool {
        return currentRound == .describe
    }
    
    func isFinalRound() -> Bool {
        return currentRound == .oneWord
    }
    
    func getRoundDisplayName() -> String {
        switch currentRound {
        case .describe:
            return "Describe"
        case .actOut:
            return "Act Out"
        case .oneWord:
            return "One Word"
        }
    }
    
    func getTeamDisplayName() -> String {
        return "Team \(currentTeam)"
    }
    
    func getOpposingTeam() -> Int {
        return currentTeam == 1 ? 2 : 1
    }
    
    func getNextRound() -> RoundType? {
        switch currentRound {
        case .describe:
            return .actOut
        case .actOut:
            return .oneWord
        case .oneWord:
            return nil // No next round
        }
    }
    
    func getRoundProgress() -> (current: Int, total: Int) {
        let currentIndex: Int
        switch currentRound {
        case .describe:
            currentIndex = 1
        case .actOut:
            currentIndex = 2
        case .oneWord:
            currentIndex = 3
        }
        return (current: currentIndex, total: 3)
    }
} 