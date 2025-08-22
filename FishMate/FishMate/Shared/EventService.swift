import Foundation

// 1. 與 API JSON 格式對應的資料模型
struct Event: Codable, Identifiable {
    let eventID: Int
    let location: String
    let eventTime: String
    let description: String
    let participantName: String

    // 將 id 對應到 eventID，這樣在 SwiftUI 中更容易使用
    var id: Int { eventID }
}

// 2. 處理 API 請求的服務
class EventService {
    
    // 從 API 獲取釣魚活動資料
    func fetchEvents() async throws -> [Event] {
        // 建立 URL
        guard let url = URL(string: "https://e62bf68bffb3.ngrok-free.app/api/Events") else {
            throw URLError(.badURL)
        }
        
        // 進行網路請求
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // 檢查伺服器回應是否成功
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // 解碼 JSON 資料
        let decoder = JSONDecoder()
        let events = try decoder.decode([Event].self, from: data)
        
        return events
    }
}
