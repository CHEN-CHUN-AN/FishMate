import SwiftUI

struct WeatherView: View {
    @Bindable var viewModel = WeatherViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Picker("選擇縣市", selection: $viewModel.selectedCity) {
                    ForEach(viewModel.cities, id: \.self) { city in
                        Text(city)
                    }
                }
                .pickerStyle(.wheel)
                .onChange(of: viewModel.selectedCity) { _, _ in
                    viewModel.updateSelectedCityWeather()
                }

                Button("查詢天氣") {
                    Task { await viewModel.fetchWeather() }
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom)

                if viewModel.isLoading {
                    ProgressView().padding()
                } else if let error = viewModel.errorMessage {
                    Text(error).foregroundColor(.red)
                } else if let info = viewModel.selectedCityWeather {
                    WeatherInfoCard(info: info)
                } else {
                    Text("請點選查詢天氣")
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .navigationTitle("天氣查詢")
            .padding()
        }
        .task {
            if viewModel.allCityWeathers.isEmpty {
                await viewModel.fetchWeather()
            }
        }
    }
}

struct WeatherInfoCard: View {
    let info: CityWeather
    var body: some View {
        VStack(spacing: 8) {
            Text(info.city)
                .font(.title2)
            Text("\(info.startTime) ~ \(info.endTime)")
                .font(.caption)
                .foregroundColor(.gray)
            Text(info.weatherDescription)
                .font(.title3)
            HStack(spacing: 24) {
                VStack {
                    Text("最高溫")
                        .font(.caption)
                    Text(info.maxTemp)
                        .bold()
                }
                VStack {
                    Text("最低溫")
                        .font(.caption)
                    Text(info.minTemp)
                        .bold()
                }
                VStack {
                    Text("降雨機率")
                        .font(.caption)
                    Text(info.pop)
                        .bold()
                }
            }
            Text(info.ci)
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
    }
}
