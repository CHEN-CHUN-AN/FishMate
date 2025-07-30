import SwiftUI

struct ContentView: View {
    @State private var selectedFunction = 0

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("🎣 FishMate")
                    .font(.largeTitle)
                    .bold()

                Picker("功能選擇", selection: $selectedFunction) {
                    Text("釣魚揪團").tag(0)
                    Text("成就分享").tag(1)
                    Text("菜單推薦").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                Divider()

                Group {
                    if selectedFunction == 0 {
                        FishingGroupView()
                    } else if selectedFunction == 1 {
                        FishAchievementsView()
                    } else {
                        FishRecipeView()
                    }
                }
                .padding()

                Spacer()
            }
            .navigationTitle("一起趣釣魚")
        }
    }
}

// MARK: - Fishing Group

struct FishingGroup: Identifiable {
    let id = UUID()
    let location: String
    let date: Date
    let note: String
    var participants: [String]
}

struct FishingGroupView: View {
    @State private var groups: [FishingGroup] = [
        FishingGroup(location: "高美濕地", date: Date(), note: "記得帶帽子！", participants: ["John", "Alice"]),
        FishingGroup(location: "淡水漁港", date: Date().addingTimeInterval(86400), note: "早上風大請穿外套", participants: ["Sam"])
    ]
    @State private var showingCreateGroup = false
    @State private var selectedGroupIndex: Int? = nil

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 15) {
                Text("目前揪團：")
                    .font(.headline)
                    .padding(.horizontal)

                List {
                    ForEach(groups.indices, id: \.self) { i in
                        ZStack {
                            if selectedGroupIndex == i {
                                Color.gray.opacity(0.2)
                            } else {
                                Color.clear
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("地點：\(groups[i].location)")
                                    Text("時間：\(groups[i].date.formatted(.dateTime.month().day().hour().minute()))")
                                    Text("說明：\(groups[i].note)")
                                    Text("參加者：\(groups[i].participants.joined(separator: ", "))")
                                }

                                if groups[i].participants.contains("你") {
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
                        .onTapGesture {
                            selectedGroupIndex = i
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color.clear)
                .scrollContentBackground(.hidden)

                Spacer(minLength: 0)
            }
            .padding(.bottom, 80)

            VStack {
                Spacer()
                Button("我要參加") {
                    if let index = selectedGroupIndex {
                        if !groups[index].participants.contains("你") {
                            groups[index].participants.append("你")
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
                    Button(action: {
                        showingCreateGroup = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title)
                            .padding()
                            .background(Color.blue)
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
                groups.append(newGroup)
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
        NavigationView {
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

// MARK: - Achievements

struct FishAchievement: Identifiable {
    let id = UUID()
    let location: String
    let species: String
    let size: String
}

struct FishAchievementsView: View {
    @State private var achievements: [FishAchievement] = [
        FishAchievement(location: "福隆海灘", species: "吳郭魚", size: "28cm"),
        FishAchievement(location: "基隆港", species: "鯛魚", size: "35cm")
    ]
    @State private var showingAdd = false

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 15) {
                Text("🏆 我的釣魚成就")
                    .font(.headline)
                    .padding(.horizontal)

                List(achievements) { fish in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("地點：\(fish.location)")
                            Text("魚種：\(fish.species)")
                            Text("大小：\(fish.size)")
                        }
                        Spacer()
                        Button(action: {
                            shareAchievement(fish)
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading) // ✅ 加這行
                }
                .listStyle(PlainListStyle())
                .background(Color.clear)
                .scrollContentBackground(.hidden)

                Spacer(minLength: 0)
            }
            .padding(.bottom, 80)

            VStack {
                Spacer()
                Button("➕ 新增成就") {
                    showingAdd = true
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showingAdd) {
            FishMeasureView(onAdd: { newAchievement in
                achievements.append(newAchievement)
            })
        }
    }

    func shareAchievement(_ achievement: FishAchievement) {
        let text = "我在 \(achievement.location) 釣到了一條 \(achievement.species)，大小 \(achievement.size)！🎣"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = scene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

struct FishMeasureView: View {
    @Environment(\.dismiss) var dismiss
    @State private var location = ""
    @State private var species = ""
    @State private var size = ""

    var onAdd: (FishAchievement) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("釣魚資訊")) {
                    TextField("地點", text: $location)
                    TextField("魚種", text: $species)
                    TextField("魚長 (公分)", text: $size)
                }

                Section {
                    Button("📏 魚類識別及測量魚長") {
                        size = "32"
                    }
                }

                Section {
                    Button("✅ 儲存成就") {
                        let newFish = FishAchievement(location: location, species: species, size: size + "cm")
                        onAdd(newFish)
                        dismiss()
                    }
                    .disabled(location.isEmpty || species.isEmpty || size.isEmpty)
                }
            }
            .navigationTitle("新增成就")
        }
    }
}

// MARK: - Recipe

struct FishRecipeView: View {
    @State private var fishName = ""
    let recipeDB: [String: [String]] = [
        "吳郭魚": ["清蒸吳郭魚", "味噌魚湯", "酥炸吳郭魚"],
        "鯛魚": ["香煎鯛魚排", "泰式檸檬鯛魚", "鯛魚味噌鍋"],
        "鱸魚": ["紅燒鱸魚", "鱸魚排佐奶油醬"],
        "鯖魚": ["味增煮鯖魚", "烤鯖魚"],
        "石斑魚": ["清蒸石斑魚", "石斑魚鍋"]
        
    ]

    var recipes: [String] {
        recipeDB[fishName] ?? ["沒有找到相關料理"]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            TextField("輸入魚種名稱", text: $fishName)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Text("推薦菜單：")
                .font(.headline)

            ForEach(recipes, id: \.self) { dish in
                HStack {
                    Text("🍽️ " + dish)
                    Spacer()
                    Button(action: {
                        let activityVC = UIActivityViewController(activityItems: ["推薦菜單：\(dish)"], applicationActivities: nil)
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let root = scene.windows.first?.rootViewController {
                            root.present(activityVC, animated: true)
                        }
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
