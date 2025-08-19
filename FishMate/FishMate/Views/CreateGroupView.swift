
import SwiftUI

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
