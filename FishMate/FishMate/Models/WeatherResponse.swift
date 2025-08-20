import Foundation

// MARK: - API 回應結構
struct WeatherResponse: Decodable {
    let records: Records
}

struct Records: Decodable {
    let location: [Location]
}

struct Location: Decodable, Identifiable {
    let id = UUID()
    let locationName: String
    let weatherElement: [WeatherElement]
}

struct WeatherElement: Decodable {
    let elementName: String
    let time: [ElementTime]
}

struct ElementTime: Decodable {
    let startTime: String
    let endTime: String
    let parameter: WeatherParameter
}

struct WeatherParameter: Decodable {
    let parameterName: String
    let parameterValue: String?
    let parameterUnit: String?
}

// MARK: - 彙整單一縣市天氣
struct CityWeather: Identifiable {
    let id = UUID()
    let city: String
    let startTime: String
    let endTime: String
    let weatherDescription: String
    let minTemp: String
    let maxTemp: String
    let pop: String
    let ci: String
}
