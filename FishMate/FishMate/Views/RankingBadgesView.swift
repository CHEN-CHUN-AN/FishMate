import SwiftUI

struct RankingBadgesView: View {
    @Bindable var app: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("🏅 排行榜")
                    .font(.headline)
                    .padding(.horizontal)

                ForEach(app.rankings) { entry in
                    HStack {
                        Text("👤 \(entry.username)")
                        Spacer()
                        Text("\(entry.title)：\(entry.score)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.08))
                    .cornerRadius(8)
                }

                Divider().padding(.vertical, 8)

                Text("🎖️ 我的徽章")
                    .font(.headline)
                    .padding(.horizontal)

                ForEach(app.badges) { badge in
                    HStack {
                        Image(systemName: badge.icon)
                            .foregroundColor(badge.achieved ? .yellow : .gray)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(badge.name)
                                .bold()
                                .foregroundColor(badge.achieved ? .primary : .secondary)
                            Text(badge.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if badge.achieved {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.06))
                    .cornerRadius(8)
                }
            }
            .padding(.vertical)
        }
    }
}
