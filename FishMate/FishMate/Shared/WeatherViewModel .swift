import Foundation
import Observation

@Observable
final class WeatherViewModel {
    var allCityWeathers: [CityWeather] = []
    var selectedCity: String = "臺北市" {
        didSet { updateSelectedCityWeather() }
    }
    var selectedCityWeather: CityWeather? = nil
    var isLoading: Bool = false
    var errorMessage: String? = nil

    let cities = [
        "臺北市", "新北市", "桃園市", "臺中市", "臺南市", "高雄市", "基隆市", "新竹市", "嘉義市",
        "新竹縣", "苗栗縣", "彰化縣", "南投縣", "雲林縣", "嘉義縣", "屏東縣", "宜蘭縣", "花蓮縣", "臺東縣", "澎湖縣", "金門縣", "連江縣"
    ]

    func fetchWeather() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let urlStr = "https://opendata.cwa.gov.tw/api/v1/rest/datastore/F-C0032-001?Authorization=CWA-35AC35A9-F3AF-4A9E-977F-6827F6C14E23"
        guard let url = URL(string: urlStr) else {
            errorMessage = "無效的API網址"
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(WeatherResponse.self, from: data)
            let weathers = decoded.records.location.compactMap { loc -> CityWeather? in
                let wx = loc.weatherElement.first(where: { $0.elementName == "Wx" })?.time.first
                let minT = loc.weatherElement.first(where: { $0.elementName == "MinT" })?.time.first
                let maxT = loc.weatherElement.first(where: { $0.elementName == "MaxT" })?.time.first
                let pop = loc.weatherElement.first(where: { $0.elementName == "PoP" })?.time.first
                let ci = loc.weatherElement.first(where: { $0.elementName == "CI" })?.time.first
                guard let wx = wx, let minT = minT, let maxT = maxT, let pop = pop, let ci = ci else {
                    return nil
                }
                return CityWeather(
                    city: loc.locationName,
                    startTime: wx.startTime,
                    endTime: wx.endTime,
                    weatherDescription: wx.parameter.parameterName,
                    minTemp: minT.parameter.parameterName + (minT.parameter.parameterUnit ?? ""),
                    maxTemp: maxT.parameter.parameterName + (maxT.parameter.parameterUnit ?? ""),
                    pop: pop.parameter.parameterName + "%",
                    ci: ci.parameter.parameterName
                )
            }
            self.allCityWeathers = weathers
            updateSelectedCityWeather()
        } catch {
            errorMessage = "資料讀取失敗: \(error.localizedDescription)"
        }
    }

    func updateSelectedCityWeather() {
        self.selectedCityWeather = allCityWeathers.first(where: { $0.city == selectedCity })
    }
}
