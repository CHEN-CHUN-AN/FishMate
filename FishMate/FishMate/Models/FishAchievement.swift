import Foundation

struct FishAchievement: Identifiable {
    let id = UUID()
    let username: String
    let location: String
    let species: String
    let sizeCM: Int
    var likeCount: Int
    var likedUsers: [String] // 新增：記錄哪些 user 按過讚
    var comments: [Comment]
}
