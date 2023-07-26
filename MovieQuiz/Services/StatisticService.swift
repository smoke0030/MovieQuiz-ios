import Foundation

protocol StatisticService {
    
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    
    func store(correct count: Int, total amount: Int)
    
}


final class StatisticServiceImplementation: StatisticService {
    
    func getCurrentTime() -> String{
        dateFormatter.dateFormat = "dd MMMM yyyy HH:mm:ss"
        let currentDate = dateFormatter.string(from: Date())
        return currentDate
    }
    
     let dateFormatter = DateFormatter()
    
    private let userDefaults = UserDefaults.standard
    
    enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    var bestGame: GameRecord  {
        
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: getCurrentTime())
            }
            
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
        
        
    }
    
    var totalAccuracy: Double {
        get {
            return Double(score) / Double(gamesCount) * 10
        }
    }
    
    var score: Int {
        get {
            userDefaults.integer(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        score += count
        let currentGameRecord = GameRecord(correct: count, total: amount, date: getCurrentTime())
        let lastGameRecord = bestGame
        if lastGameRecord < currentGameRecord {
            bestGame = currentGameRecord
        }
        
        
    }

}
