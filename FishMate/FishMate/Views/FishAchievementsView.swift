import SwiftUI

struct FishAchievementsView: View {
    @Bindable var app: AppState
    @State private var showingAdd = false
    @State private var activeCommentsIndex: Int? = nil

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 15) {
                Text("🏆 我的釣魚成就")
                    .font(.headline)
                    .padding(.horizontal)

                List {
                    ForEach(app.achievements.indices, id: \.self) { i in
                        let fish = app.achievements[i]
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
                                    Label("\(fish.likeCount)", systemImage: fish.likedUsers.contains("你") ? "hand.thumbsup.fill" : "hand.thumbsup")
                                }
                                .disabled(fish.likedUsers.contains("你"))
                                Button(action: { activeCommentsIndex = i }) {
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
        .sheet(isPresented: Binding(get: { activeCommentsIndex != nil },
                                   set: { if !$0 { activeCommentsIndex = nil } })) {
            if let idx = activeCommentsIndex {
                CommentsSheet(comments: $app.achievements[idx].comments)
            }
        }
    }

    func like(_ achievement: FishAchievement) {
        let userId = "你" // 或改成登入用戶ID
        if let idx = app.achievements.firstIndex(where: { $0.id == achievement.id }) {
            if !app.achievements[idx].likedUsers.contains(userId) {
                app.achievements[idx].likeCount += 1
                app.achievements[idx].likedUsers.append(userId)
            }
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
