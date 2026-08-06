import UIKit

final class StatisticService: StatisticServiceProtocol {
    

    private enum Keys: String {
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case totalCorrect
    }
    private let storage: UserDefaults = .standard
    
    // MARK: - Счетчик
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    // MARK: - Лучшее
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    private var totalCorrectAnswers: Int {
        get { storage.integer(forKey: Keys.totalCorrect.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalCorrect.rawValue)
        }
    }
    
    // MARK: - Среднее
    
    var totalAccuracy: Double {
        let totalQuestionsAsked = gamesCount * 10
        guard totalQuestionsAsked > 0 else { return 0 }
        return (Double(totalCorrectAnswers) / Double(totalQuestionsAsked)) * 100
    }
    
    // MARK: - Сохранение
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        totalCorrectAnswers += count
        let currentGame = GameResult(correct: count, total: amount, date: Date())
        if currentGame.isBetterThan(bestGame) {
            bestGame = currentGame
        }
    }
}
