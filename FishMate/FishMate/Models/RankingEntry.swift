import Foundation

struct RankingEntry: Identifiable {
    let id = UUID()
    let username: String
    let title: String
    let score: Int
}
