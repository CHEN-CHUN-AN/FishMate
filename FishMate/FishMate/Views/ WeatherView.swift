import SwiftUI

struct WeatherView: View {
    @State private var viewModel = WeatherViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("載入中…")
                        .padding()
                } else if let error = viewModel.errorMessage {
                    Text("錯誤：\(error)")
                        .foregroundStyle(.red)
                        .padding()
                } else if !viewModel.locations.isEmpty {
                    Picker("選擇縣市", selection: $viewModel.selectedLocation) {
                        ForEach(viewModel.locations, id: \.self) { loc in
                            Text(loc.locationName).tag(loc as WeatherLocation?)
                        }
                    }
                    .pickerStyle(.wheel)
                    .padding()

                    if let location = viewModel.selectedLocation {
                        List {
                            ForEach(0..<3, id: \.self) { index in
                                let wx = location.weatherElement.first(where: { $0.elementName == "Wx" })?.time[safe: index]
                                let pop = location.weatherElement.first(where: { $0.elementName == "PoP" })?.time[safe: index]
                                let minT = location.weatherElement.first(where: { $0.elementName == "MinT" })?.time[safe: index]
                                let maxT = location.weatherElement.first(where: { $0.elementName == "MaxT" })?.time[safe: index]
                                let ci = location.weatherElement.first(where: { $0.elementName == "CI" })?.time[safe: index]
                                Section(header: Text("\(wx?.startTime ?? "") ~ \(wx?.endTime ?? "")")) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("天氣：\(wx?.parameter.parameterName ?? "--")")
                                        Text("降雨機率：\(pop?.parameter.parameterName ?? "--")%")
                                        Text("溫度：\(minT?.parameter.parameterName ?? "--")~\(maxT?.parameter.parameterName ?? "--")℃")
                                        Text("體感：\(ci?.parameter.parameterName ?? "--")")
                                    }
                                    .font(.callout)
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                } else {
                    Text("暫無資料")
                        .padding()
                }
            }
            .navigationTitle("天氣查詢")
            .task {
                await viewModel.loadWeather()
            }
        }
    }
}

// 安全下標 (Swift 5.8+)
extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
