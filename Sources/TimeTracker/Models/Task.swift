import Foundation

public struct Task: Codable, Identifiable, Hashable, Sendable {
    public var id: UUID
    public var title: String
    public var phase: String?
    public var isCompleted: Bool
    public var timeLogs: [TimeLog]
    
    public init(id: UUID = UUID(), title: String, phase: String? = nil, isCompleted: Bool = false, timeLogs: [TimeLog] = []) {
        self.id = id
        self.title = title
        self.phase = phase
        self.isCompleted = isCompleted
        self.timeLogs = timeLogs
    }
    
    public var totalTimeSpent: TimeInterval {
        timeLogs.reduce(0) { $0 + $1.duration }
    }
}
