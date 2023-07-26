import Foundation

struct GameRecord: Codable, Comparable    {
    let correct: Int
    let total: Int
    let date: String
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.correct < rhs.correct
    }
    
}



