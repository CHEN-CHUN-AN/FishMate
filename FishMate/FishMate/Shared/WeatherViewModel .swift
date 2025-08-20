import Foundation

@Observable
final class WeatherViewModel {
    var locations: [WeatherLocation] = []
    var selectedLocation: WeatherLocation?
    var isLoading = false
    var errorMessage: String?

    func loadWeather() async {
        isLoading = true
        do {
            let result = try await WeatherService.shared.fetchWeather()
            locations = result
            if selectedLocation == nil {
                selectedLocation = locations.first
            }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
