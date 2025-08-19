import SwiftUI

struct FishAchievementsView: View {
    @Bindable var app: AppState
    @State private var showingAdd = false
    @State private var activeCommentsFor: FishAchievement? = nil

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 15) {
                Text("🏆 我的釣魚成就")
                    .font(.headline)
                    .padding(.horizontal)

                List {
                    ForEach(app.achievements) { fish in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("使用者：\(fish.username)")
                                    Text("地點：\(fish.location)")
                                    Text("魚種：\(fish.species)")
                                    Text("大小：\(fish.sizeCM) cm")
                                }
                                Spacer()
                                ShareButton(achievement: fish)
                            }

                            HStack(spacing: 16) {
                                Button(action: { like(fish) }) {
                                    Label("\(fish.likeCount)", systemImage: "hand.thumbsup")
                                }

                                Button(action: { activeCommentsFor = fish }) {
                                    Label("\(fish.comments.count)", systemImage: "text.bubble")
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .listStyle(.plain)
                .background(.clear)
                .scrollContentBackground(.hidden)

                Spacer(minLength: 0)
            }
            .padding(.bottom, 80)

            VStack {
                Spacer()
                Button("➕ 新增成就") { showingAdd = true }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showingAdd) {
            FishMeasureView(onAdd: { newAchievement in
                app.achievements.append(newAchievement)
            })
        }
        .sheet(item: $activeCommentsFor) { ach in
            CommentsSheet(achievement: ach) { text in
                addComment(text, to: ach)
            }
        }
    }

    func like(_ achievement: FishAchievement) {
        if let idx = app.achievements.firstIndex(where: { $0.id == achievement.id }) {
            app.achievements[idx].likeCount += 1
        }
    }

    func addComment(_ text: String, to achievement: FishAchievement) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        if let idx = app.achievements.firstIndex(where: { $0.id == achievement.id }) {
            app.achievements[idx].comments.append(Comment(author: "你", text: text))
        }
    }
}

struct ShareButton: View {
    let achievement: FishAchievement

    var body: some View {
        Button(action: { shareAchievement() }) {
            Image(systemName: "square.and.arrow.up")
                .foregroundColor(.blue)
        }
    }

    func shareAchievement() {
        let text = "我在 \(achievement.location) 釣到了一條 \(achievement.species)，大小 \(achievement.sizeCM)cm！🎣"
    #if canImport(UIKit)
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = scene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    #endif
    }
}

struct CommentsSheet: View {
    let achievement: FishAchievement
    var onSend: (String) -> Void

    @Environment(\.dismiss) var dismiss
    @State private var newText = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                List {
                    Section("留言") {
                        ForEach(achievement.comments) { c in
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
                        onSend(newText)
                        newText = ""
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("💬 留言板")
            .toolbar { ToolbarItem(placement: .primaryAction) { Button("完成") { dismiss() } } }
        }
    }
} 
