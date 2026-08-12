import Foundation

public struct TimeLog: Codable, Identifiable, Hashable, Sendable {
    public var id: UUID
    public var startTime: Date
    public var endTime: Date?
    public var intent: String?
    
    public init(id: UUID = UUID(), startTime: Date = Date(), endTime: Date? = nil, intent: String? = nil) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.intent = intent
    }
    
    public var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }
}
