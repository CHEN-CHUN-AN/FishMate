import SwiftUI

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
                    Text("天氣查詢").tag(4)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Divider()

                Group {
                    switch selectedTab {
                    case 0: AnyView(FishingGroupView(app: app))
                    case 1: AnyView(FishAchievementsView(app: app))
                    case 2: AnyView(FishRecipeView(app: app))
                    case 3: AnyView(RankingBadgesView(app: app))
                    case 4: AnyView(WeatherView()) // 不帶 app
                    default: AnyView(WeatherView())
                    }
                }
                .padding()

                Spacer(minLength: 0)
            }
            .navigationTitle("一起趣釣魚")
        }
    }
}
