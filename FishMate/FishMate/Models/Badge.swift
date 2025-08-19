import Foundation

struct Badge: Identifiable {
    let id = UUID()
    let key: BadgeKey
    let name: String
    let icon: String
    var achieved: Bool
    let description: String
}
