import Foundation

struct FishAchievement: Identifiable {
    let id = UUID()
    let username: String
    let location: String
    let species: String
    let sizeCM: Int
    var likeCount: Int
    var comments: [Comment]
}
