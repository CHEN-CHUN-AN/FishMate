import Foundation

@Observable
final class AppState {
    // Groups
    var groups: [FishingGroup] = [
        FishingGroup(location: "高美濕地", date: .now, note: "記得帶帽子！", participants: ["John", "Alice"]),
        FishingGroup(location: "淡水漁港", date: .now.addingTimeInterval(86400), note: "早上風大請穿外套", participants: ["Sam"])
    ]

    // Achievements (social)
    var achievements: [FishAchievement] = [
        FishAchievement(username: "你", location: "福隆海灘", species: "吳郭魚", sizeCM: 28, likeCount: 2,likedUsers: [], comments: [Comment(author: "Alice", text: "好厲害！")]),
        FishAchievement(username: "你", location: "基隆港", species: "鯛魚", sizeCM: 35, likeCount: 1,likedUsers: [], comments: [])
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
            entries.append(RankingEntry(username: "班傑明", title: "最大魚王", score: maxSize))
            entries.append(RankingEntry(username: "愛麗絲", title: "最多魚種", score: uniqueSpecies))
            entries.append(RankingEntry(username: "湯姆", title: "最活躍釣友", score: activity))
        }
        rankings = entries.sorted { $0.score > $1.score }.prefix(10).map { $0 }
    }
}
