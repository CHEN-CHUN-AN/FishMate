import Foundation

struct FishingGroup: Identifiable {
    let id = UUID()
    let location: String
    let date: Date
    let note: String
    var participants: [String]
}
