import Foundation

public enum PomodoroState: String, Codable, Hashable, Sendable {
    case inactive
    case focus
    case shortBreak
    case longBreak
}
