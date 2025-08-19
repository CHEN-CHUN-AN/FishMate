import SwiftUI

struct FishMeasureView: View {
    @Environment(\.dismiss) var dismiss

    @State private var location = ""
    @State private var species = ""
    @State private var size = ""
    var onAdd: (FishAchievement) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("釣魚紀錄")) {
                    TextField("地點", text: $location)
                    TextField("魚種", text: $species)
                    TextField("大小 (cm)", text: $size)
                        .keyboardType(.numberPad)
                }
                Section {
                    Button("新增成就") {
                        let sz = Int(size) ?? 0
                        let achievement = FishAchievement(
                            username: "你",
                            location: location,
                            species: species,
                            sizeCM: sz,
                            likeCount: 0,
                            comments: []
                        )
                        onAdd(achievement)
                        dismiss()
                    }
                    .disabled(location.isEmpty || species.isEmpty || Int(size) == nil)
                }
            }
            .navigationTitle("新增釣魚成就")
        }
    }
}
