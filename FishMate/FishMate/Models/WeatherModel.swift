import Foundation

struct WeatherResponse: Codable, Equatable, Hashable {
    let records: Records
}

struct Records: Codable, Equatable, Hashable {
    let location: [WeatherLocation]
}

struct WeatherLocation: Codable, Equatable, Hashable, Identifiable {
    var id: String { locationName }
    let locationName: String
    let weatherElement: [WeatherElement]
}

struct WeatherElement: Codable, Equatable, Hashable {
    let elementName: String
    let time: [WeatherTime]
}

struct WeatherTime: Codable, Equatable, Hashable {
    let startTime: String
    let endTime: String
    let parameter: WeatherParameter
}

struct WeatherParameter: Codable, Equatable, Hashable {
    let parameterName: String
    let parameterValue: String?
    let parameterUnit: String?
}
