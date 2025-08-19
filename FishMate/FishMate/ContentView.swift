// MARK: - FishMate – Full SwiftUI Sample Project (iOS 18+ Ready)
// Features included:
// 1) 釣魚揪團 (原功能)
// 2) 成就分享 + 👍按讚、💬留言 (社群互動)
// 3) 智慧推薦食譜：依魚種 + 魚長大小推薦
// 4) 排行榜 + 成就徽章（自動解鎖）

import SwiftUI


// MARK: - AppState (Shared Data)
@Observable
final class AppState {
    // Groups
    var groups: [FishingGroup] = [
        FishingGroup(location: "高美濕地", date: .now, note: "記得帶帽子！", participants: ["John", "Alice"]),
        FishingGroup(location: "淡水漁港", date: .now.addingTimeInterval(86400), note: "早上風大請穿外套", participants: ["Sam"])
    ]

    // Achievements (social)
    var achievements: [FishAchievement] = [
        FishAchievement(username: "你", location: "福隆海灘", species: "吳郭魚", sizeCM: 28, likeCount: 2, comments: [Comment(author: "Alice", text: "好厲害！")]),
        FishAchievement(username: "你", location: "基隆港", species: "鯛魚", sizeCM: 35, likeCount: 1, comments: [])
    ] {
        didSet { recomputeBadgesAndRanking() }
    }

    // Badges
    var badges: [Badge] = [
        Badge(key: .firstCatch, name: "初次釣魚", icon: "fish", achieved: false, description: "新增第一筆成就"),
        Badge(key: .size50, name: "50cm 突破", icon: "star", achieved: false, description: "魚長達 50cm"),
        Badge(key: .species10, name: "魚種收藏家", icon: "crown", achieved: false, description: "收集 10 種魚")
    ]

    // Rankings (recomputed from achievements)
    var rankings: [RankingEntry] = []

    // Recipe DB (base)
    let recipeDB: [String: [String]] = [
        "吳郭魚": ["清蒸吳郭魚", "味噌魚湯", "酥炸吳郭魚"],
        "鯛魚": ["香煎鯛魚排", "泰式檸檬鯛魚", "鯛魚味噌鍋"],
        "鱸魚": ["紅燒鱸魚", "鱸魚排佐奶油醬"],
        "鯖魚": ["味增煮鯖魚", "烤鯖魚"],
        "石斑魚": ["清蒸石斑魚", "石斑魚鍋"]
    ]

    init() { recomputeBadgesAndRanking() }

    // MARK: - Badge + Ranking Logic
    func recomputeBadgesAndRanking() {
        // Badges
        var achievedBadges = Set<BadgeKey>()
        if !achievements.isEmpty { achievedBadges.insert(.firstCatch) }
        if achievements.contains(where: { $0.sizeCM >= 50 }) { achievedBadges.insert(.size50) }
        let speciesCount = Set(achievements.map(\.species)).count
        if speciesCount >= 10 { achievedBadges.insert(.species10) }

        badges = badges.map { b in
            var nb = b
            nb.achieved = achievedBadges.contains(b.key)
            return nb
        }

        // Rankings
        let byUser = Dictionary(grouping: achievements, by: \.username)
        var entries: [RankingEntry] = []
        for (user, records) in byUser {
            let maxSize = records.map(\.sizeCM).max() ?? 0
            let uniqueSpecies = Set(records.map(\.species)).count
            let activity = records.count
            entries.append(RankingEntry(username: user, title: "最大魚王", score: maxSize))
            entries.append(RankingEntry(username: user, title: "最多魚種", score: uniqueSpecies))
            entries.append(RankingEntry(username: user, title: "最活躍釣友", score: activity))
        }
        rankings = entries.sorted { $0.score > $1.score }.prefix(10).map { $0 }
    }
}

// MARK: - Models
struct FishingGroup: Identifiable {
    let id = UUID()
    let location: String
    let date: Date
    let note: String
    var participants: [String]
}

struct Comment: Identifiable, Hashable {
    let id = UUID()
    let author: String
    let text: String
}

struct FishAchievement: Identifiable {
    let id = UUID()
    let username: String
    let location: String
    let species: String
    let sizeCM: Int
    var likeCount: Int
    var comments: [Comment]
}

enum BadgeKey: Hashable, Sendable { case firstCatch, size50, species10 }

struct Badge: Identifiable {
    let id = UUID()
    let key: BadgeKey
    let name: String
    let icon: String
    var achieved: Bool
    let description: String
}

struct RankingEntry: Identifiable {
    let id = UUID()
    let username: String
    let title: String
    let score: Int
}

// MARK: - Root UI
struct ContentView: View {
    @State private var app = AppState()
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("🎣 FishMate").font(.largeTitle).bold()

                Picker("功能選擇", selection: $selectedTab) {
                    Text("釣魚揪團").tag(0)
                    Text("成就分享").tag(1)
                    Text("菜單推薦").tag(2)
                    Text("排行/徽章").tag(3)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Divider()

                Group {
                    switch selectedTab {
                    case 0: FishingGroupView(app: app)
                    case 1: FishAchievementsView(app: app)
                    case 2: FishRecipeView(app: app)
                    default: RankingBadgesView(app: app)
                    }
                }
                .padding()

                Spacer(minLength: 0)
            }
            .navigationTitle("一起趣釣魚")
        }
    }
}

// MARK: - Fishing Group
struct FishingGroupView: View {
    @Bindable var app: AppState
    @State private var showingCreateGroup = false
    @State private var selectedGroupIndex: Int? = nil

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 15) {
                Text("目前揪團：")
                    .font(.headline)
                    .padding(.horizontal)

                List {
                    ForEach(app.groups.indices, id: \.self) { i in
                        ZStack {
                            if selectedGroupIndex == i {
                                Color.gray.opacity(0.2)
                            } else { Color.clear }

                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("地點：\(app.groups[i].location)")
                                    Text("時間：\(app.groups[i].date.formatted(.dateTime.month().day().hour().minute()))")
                                    Text("說明：\(app.groups[i].note)")
                                    Text("參加者：\(app.groups[i].participants.joined(separator: ", "))")
                                }

                                if app.groups[i].participants.contains("你") {
                                    Text("✅ 已參加")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .cornerRadius(8)
                        .onTapGesture { selectedGroupIndex = i }
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
                Button("我要參加") {
                    if let index = selectedGroupIndex {
                        if !app.groups[index].participants.contains("你") {
                            app.groups[index].participants.append("你")
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingCreateGroup = true }) {
                        Image(systemName: "plus")
                            .font(.title)
                            .padding()
                            .background(.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                            .padding()
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreateGroup) {
            CreateGroupView { newGroup in
                app.groups.append(newGroup)
            }
        }
    }
}

struct CreateGroupView: View {
    @Environment(\.dismiss) var dismiss
    @State private var location = ""
    @State private var note = ""
    @State private var date = Date()
    var onCreate: (FishingGroup) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("揪團資訊")) {
                    TextField("釣場地點", text: $location)
                    DatePicker("時間", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    TextEditor(text: $note)
                        .frame(height: 80)
                }

                Section {
                    Button("建立揪團") {
                        let newGroup = FishingGroup(location: location, date: date, note: note, participants: ["你"])
                        onCreate(newGroup)
                        dismiss()
                    }
                    .disabled(location.isEmpty || note.isEmpty)
                }
            }
            .navigationTitle("新增揪團")
        }
    }
}

// MARK: - Achievements (with Likes & Comments)
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

// MARK: - Add Achievement Form
struct FishMeasureView: View {
    @Environment(\.dismiss) var dismiss
    @State private var location = ""
    @State private var species = ""
    @State private var sizeText = ""

    var onAdd: (FishAchievement) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("釣魚資訊")) {
                    TextField("地點", text: $location)
                    TextField("魚種", text: $species)
                    TextField("魚長 (公分)", text: $sizeText)
                        .keyboardType(.numberPad)
                }

                Section {
                    Button("📏（示範）自動測量 -> 32cm") {
                        sizeText = "32"
                    }
                }

                Section {
                    Button("✅ 儲存成就") {
                        let size = Int(sizeText) ?? 0
                        let newFish = FishAchievement(username: "你", location: location, species: species, sizeCM: size, likeCount: 0, comments: [])
                        onAdd(newFish)
                        dismiss()
                    }
                    .disabled(location.isEmpty || species.isEmpty || sizeText.isEmpty)
                }
            }
            .navigationTitle("新增成就")
        }
    }
}

// MARK: - Smart Recipe View
struct FishRecipeView: View {
    @Bindable var app: AppState
    @State private var fishName = ""
    @State private var sizeText = ""
    @State private var pantry = "" // 預留：冰箱食材（可選）

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("輸入魚種名稱（例：鯛魚）", text: $fishName)
                .textFieldStyle(.roundedBorder)
            TextField("輸入魚長（cm）", text: $sizeText)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
            TextField("可用食材（可留空，逗號分隔）", text: $pantry)
                .textFieldStyle(.roundedBorder)

            Text("推薦菜單：").font(.headline)

            let size = Int(sizeText) ?? 0
            let recipes = smartRecipes(for: fishName, size: size, baseDB: app.recipeDB, pantry: pantry)

            ForEach(recipes, id: \.self) { dish in
                HStack {
                    Text("🍽️ " + dish)
                    Spacer()
                    ShareRecipeButton(dish: dish)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct ShareRecipeButton: View {
    let dish: String

    var body: some View {
        Button(action: {
            shareRecipe()
        }) {
            Image(systemName: "square.and.arrow.up")
        }
    }

    func shareRecipe() {
#if canImport(UIKit)
        let activityVC = UIActivityViewController(activityItems: ["推薦菜單：\(dish)"], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(activityVC, animated: true)
        }
#endif
    }
}

func smartRecipes(for fish: String, size: Int, baseDB: [String: [String]], pantry: String) -> [String] {
    let fallback = ["沒有找到相關料理"]
    let base = baseDB[fish].map { Array($0.prefix(3)) } ?? fallback

    // Size-based augment
    var extra: [String] = []
    if size > 0 {
        if size < 30 {
            extra += ["香煎\(fish)", "紅燒\(fish)"]
        } else if size < 50 {
            extra += ["清蒸\(fish)", "味噌湯\(fish)"]
        } else {
            extra += ["火鍋大餐：\(fish)", "鹽烤整尾\(fish)"]
        }
    }

    // Pantry-based filter (simple contains-any matching)
    let tokens = Set(pantry.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty })
    if !tokens.isEmpty {
        let filtered = (base + extra).filter { dish in
            // naive keywords match
            let joined = dish
            return tokens.contains(where: { joined.localizedCaseInsensitiveContains($0) })
        }
        if !filtered.isEmpty { return Array(filtered.prefix(6)) }
    }

    return Array((base + extra).prefix(6))
}

// MARK: - Ranking + Badges
struct RankingBadgesView: View {
    @Bindable var app: AppState
    @State private var selection = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("", selection: $selection) {
                Text("排行榜").tag(0)
                Text("徽章").tag(1)
            }
            .pickerStyle(.segmented)

            if selection == 0 { RankingView(app: app) } else { BadgesView(app: app) }
        }
        .padding(.horizontal)
    }
}

struct RankingView: View {
    @Bindable var app: AppState

    var body: some View {
        VStack(alignment: .leading) {
            Text("🏆 排行榜（示範）")
                .font(.title3).bold()
                .padding(.bottom, 6)

            List(app.rankings) { r in
                HStack {
                    VStack(alignment: .leading) {
                        Text(r.username).font(.headline)
                        Text(r.title).font(.caption).foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("\(r.score)")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
            .listStyle(.plain)
        }
    }
}

struct BadgesView: View {
    @Bindable var app: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🎖 我的徽章")
                .font(.title3).bold()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(app.badges) { b in
                        VStack(spacing: 8) {
                            Image(systemName: b.icon)
                                .font(.largeTitle)
                                .foregroundColor(b.achieved ? .yellow : .gray)
                                .padding()
                                .background(
                                    Circle().fill((b.achieved ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.2)))
                                )
                            Text(b.name)
                                .font(.caption)
                            Text(b.description)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .frame(width: 100)
                        }
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
}
