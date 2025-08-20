import Foundation

@Observable
final class WeatherService {
    static let shared = WeatherService()
    private init() {}

    let apiURL = "https://opendata.cwa.gov.tw/api/v1/rest/datastore/F-C0032-001?Authorization=CWA-35AC35A9-F3AF-4A9E-977F-6827F6C14E23"

    func fetchWeather() async throws -> [WeatherLocation] {
        guard let url = URL(string: apiURL) else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
        return weatherResponse.records.location
    }
}
