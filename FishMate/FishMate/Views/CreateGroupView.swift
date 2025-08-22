import SwiftUI

struct CreateGroupView: View {
    @Environment(\.dismiss) var dismiss
    @State private var location = ""
    @State private var note = ""
    @State private var date = Date()
    @State private var eventID = 0 // 可改由外部管理
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
                        submitGroup()
                    }
                    .disabled(location.isEmpty || note.isEmpty)
                }
            }
            .navigationTitle("新增揪團")
        }
    }

    func submitGroup() {
        let apiURL = URL(string: "https://e62bf68bffb3.ngrok-free.app/api/Events")!
        let formatter = ISO8601DateFormatter()
        let parameters: [String: Any] = [
            "eventID": eventID, 
            "location": location,
            "eventTime": formatter.string(from: date),
            "description": note,
            "participantName": "你"
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: parameters) else { return }

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse,
                     httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                DispatchQueue.main.async {
                    eventID += 1
                    let newGroup = FishingGroup(location: location, date: date, note: note, participants: ["你"])
                    onCreate(newGroup)
                    dismiss()
                }
               
            }
        }.resume()
    }
}
