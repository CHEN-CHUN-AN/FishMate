import SwiftUI

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
                        .contentShape(Rectangle()) // 這行是關鍵！
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
                            // 按鈕會依據是否已參加顯示不同內容
                            if let index = selectedGroupIndex {
                                if app.groups[index].participants.contains("你") {
                                    Button("取消參加") {
                                        if let idx = app.groups[index].participants.firstIndex(of: "你") {
                                            app.groups[index].participants.remove(at: idx)
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal)
                                    .padding(.bottom, 20)
                                } else {
                                    Button("我要參加") {
                                        if !app.groups[index].participants.contains("你") {
                                            app.groups[index].participants.append("你")
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal)
                                    .padding(.bottom, 20)
                                }
                            }
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
