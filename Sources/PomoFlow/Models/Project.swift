import Foundation

public struct Project: Codable, Identifiable, Hashable, Sendable {
    public var id: UUID
    public var name: String
    public var hourlyRate: Double?
    public var tasks: [Task]

    public init(id: UUID = UUID(), name: String, hourlyRate: Double? = nil, tasks: [Task] = []) {
        self.id = id
        self.name = name
        self.hourlyRate = hourlyRate
        self.tasks = tasks
    }
}
