import SwiftUI

struct CommentsSheet: View {
    @Binding var comments: [Comment]
    @Environment(\.dismiss) var dismiss
    @State private var newText = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                List {
                    Section("留言") {
                        ForEach(comments) { c in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(c.author).font(.caption).foregroundColor(.secondary)
                                Text(c.text)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                HStack {
                    TextField("輸入留言…", text: $newText)
                        .textFieldStyle(.roundedBorder)
                    Button("送出") {
                        let trimmed = newText.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty {
                            comments.append(Comment(author: "你", text: trimmed))
                        }
                        newText = ""
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("💬 留言板")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}
