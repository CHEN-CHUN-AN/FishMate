import SwiftUI

struct FishRecipeView: View {
    @Bindable var app: AppState
    @State private var species = ""
    @State private var recipes: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("🍲 釣魚食譜推薦")
                .font(.headline)
                .padding(.horizontal)

            HStack {
                TextField("請輸入魚種…", text: $species)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                Button("查詢") { searchRecipe() }
                    .buttonStyle(.borderedProminent)
            }

            if !recipes.isEmpty {
                Text("推薦食譜：")
                    .font(.subheadline)
                    .padding(.horizontal)
                ForEach(recipes, id: \.self) { r in
                    Text("- \(r)").padding(.horizontal)
                }
            } else if !species.isEmpty {
                Text("沒有找到相關食譜，歡迎自行發揮創意！")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }

            Spacer(minLength: 0)
        }
    }

    func searchRecipe() {
        let trimmed = species.trimmingCharacters(in: .whitespacesAndNewlines)
        if let r = app.recipeDB[trimmed] {
            recipes = r
        } else {
            recipes = []
        }
    }
}
