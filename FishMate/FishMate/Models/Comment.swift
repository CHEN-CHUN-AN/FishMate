import Foundation

struct Comment: Identifiable, Hashable {
    let id = UUID()
    let author: String
    let text: String
}
