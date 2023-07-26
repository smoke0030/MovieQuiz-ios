import Foundation

struct GameRecord: Codable, Comparable    {
    let correct: Int
    let total: Int
    let date: Date
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.correct < rhs.correct
    }
    
}



