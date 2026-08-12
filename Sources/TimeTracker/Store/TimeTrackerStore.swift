import Foundation
import Observation
#if os(macOS)
import AppKit
import UserNotifications
#endif

public enum AppScreen: Hashable {
    case projects, reports, settings
}

@MainActor
@Observable
public class TimeTrackerStore {
    public var projects: [Project] = []
    public var selectedTab: AppScreen = .projects
    public var activeProjectID: UUID?
    public var activeTaskID: UUID?
    
    public var isTaskRunning: Bool = false
    
    public var todayTotalTime: TimeInterval = 0
    public var todayPomodoros: Int = 0
    
    public var pomodoroState: PomodoroState = .inactive
    public var pomodoroTimeRemaining: TimeInterval = 0
    private var pomodoroTargetDate: Date?
    public var currentIntent: String?
    
    public var formattedTime: String? {
        if pomodoroState != .inactive {
            return timeString(from: pomodoroTimeRemaining)
        } else if isTaskRunning, let pID = activeProjectID, let tID = activeTaskID,
                  let project = projects.first(where: { $0.id == pID }),
                  let task = project.tasks.first(where: { $0.id == tID }) {
            return timeString(from: task.totalTimeSpent)
        }
        return nil
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(timeInterval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private let storageManager = StorageManager.shared
    private var timerTask: Swift.Task<Void, Never>?
    private var activity: NSObjectProtocol?
    private var lastSaveTime: Date = Date()
    
    public init() {}
    
    public func loadData() async {
        do {
            let loadedProjects = try await storageManager.loadActiveProjects()
            self.projects = loadedProjects
            self.updateDailyStats()
        } catch {
            print("Error loading projects: \(error)")
        }
    }
    
    public func updateDailyStats() {
        let calendar = Calendar.current
        
        let total = projects.flatMap { $0.tasks }
            .flatMap { $0.timeLogs }
            .filter { calendar.isDateInToday($0.startTime) }
            .reduce(0) { $0 + $1.duration }
            
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd"
        let dateString = formatter.string(from: Date())
        
        let genericTime = UserDefaults.standard.double(forKey: "generic_focus_\(dateString)")
            
        self.todayTotalTime = total + genericTime
        
        self.todayPomodoros = UserDefaults.standard.integer(forKey: "pomodoros_\(dateString)")
        
        updateStreakLogic()
    }
    
    public var currentStreak: Int = 0
    
    private func updateStreakLogic() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd"
        let todayString = formatter.string(from: Date())
        let defaults = UserDefaults.standard
        
        let streak = defaults.integer(forKey: "currentStreak")
        let lastActive = defaults.string(forKey: "lastActiveDate")
        
        let calendar = Calendar.current
        if let lastActive = lastActive, let lastDate = formatter.date(from: lastActive) {
            let isYesterday = calendar.isDateInYesterday(lastDate)
            let isToday = calendar.isDateInToday(lastDate)
            
            if isToday {
                self.currentStreak = streak
            } else if isYesterday {
                if self.todayTotalTime > 0 || self.todayPomodoros > 0 {
                    self.currentStreak = streak + 1
                    defaults.set(todayString, forKey: "lastActiveDate")
                    defaults.set(self.currentStreak, forKey: "currentStreak")
                } else {
                    self.currentStreak = streak
                }
            } else {
                // Was not yesterday or today, streak lost?
                // Only if today they did something, start at 1
                if self.todayTotalTime > 0 || self.todayPomodoros > 0 {
                    self.currentStreak = 1
                    defaults.set(todayString, forKey: "lastActiveDate")
                    defaults.set(self.currentStreak, forKey: "currentStreak")
                } else {
                    self.currentStreak = 0 // lost streak
                }
            }
        } else {
            // First time
            if self.todayTotalTime > 0 || self.todayPomodoros > 0 {
                self.currentStreak = 1
                defaults.set(todayString, forKey: "lastActiveDate")
                defaults.set(self.currentStreak, forKey: "currentStreak")
            }
        }
    }
    
    public func saveData() {
        let currentProjects = projects
        Swift.Task {
            do {
                try await storageManager.saveActiveProjects(currentProjects)
            } catch {
                print("Error saving projects: \(error)")
            }
        }
    }
    
    public func startTask(projectID: UUID, taskID: UUID) {
        if isTaskRunning {
            pauseActiveTask()
        }
        activeProjectID = projectID
        activeTaskID = taskID
        
        resumeActiveTask()
    }
    
    public func resumeActiveTask() {
        guard let pID = activeProjectID, let tID = activeTaskID else { return }
        if let pIndex = projects.firstIndex(where: { $0.id == pID }),
           let tIndex = projects[pIndex].tasks.firstIndex(where: { $0.id == tID }) {
            let newLog = TimeLog(intent: currentIntent)
            projects[pIndex].tasks[tIndex].timeLogs.append(newLog)
            isTaskRunning = true
            saveData()
            evaluateTimerState()
        }
    }
    
    public func pauseActiveTask() {
        if let pID = activeProjectID, let tID = activeTaskID {
            if let pIndex = projects.firstIndex(where: { $0.id == pID }),
               let tIndex = projects[pIndex].tasks.firstIndex(where: { $0.id == tID }) {
                if let lastLogIndex = projects[pIndex].tasks[tIndex].timeLogs.indices.last {
                    projects[pIndex].tasks[tIndex].timeLogs[lastLogIndex].endTime = Date()
                    saveData()
                }
            }
        }
        
        isTaskRunning = false
        evaluateTimerState()
    }
    
    public func stopActiveTask() {
        pauseActiveTask()
        activeProjectID = nil
        activeTaskID = nil
    }
    
    public func togglePomodoro() {
        if pomodoroState == .inactive {
            let focusMinutes = UserDefaults.standard.integer(forKey: "pomodoroFocusMinutes")
            let minutes = focusMinutes > 0 ? focusMinutes : 25
            
            pomodoroState = .focus
            pomodoroTimeRemaining = TimeInterval(minutes * 60)
            pomodoroTargetDate = Date().addingTimeInterval(pomodoroTimeRemaining)
            
            #if os(macOS)
            FocusModeManager.enableDoNotDisturb()
            applyStrictFocusMode(enabled: true)
            #endif
        } else {
            pomodoroState = .inactive
            pomodoroTimeRemaining = 0
            pomodoroTargetDate = nil
            #if os(macOS)
            applyStrictFocusMode(enabled: false)
            #endif
        }
        evaluateTimerState()
    }
    
    private func applyStrictFocusMode(enabled: Bool) {
        #if os(macOS)
        guard UserDefaults.standard.bool(forKey: "strictFocusMode") else { return }
        
        DispatchQueue.main.async {
            if enabled {
                NSApplication.shared.hideOtherApplications(nil)
            } else {
                NSApplication.shared.unhideAllApplications(nil)
            }
        }
        #endif
    }
    
    private func evaluateTimerState() {
        let needsTimer: Bool
        if isTaskRunning {
            needsTimer = true
        } else if pomodoroState == .shortBreak || pomodoroState == .longBreak {
            needsTimer = true
        } else if pomodoroState == .focus && activeTaskID == nil {
            needsTimer = true
        } else {
            needsTimer = false
        }
        
        if needsTimer {
            if timerTask == nil {
                startTimer()
            }
        } else {
            stopTimer()
        }
        updateDockBadge()
    }
    
    private func startTimer() {
        if activity == nil {
            activity = ProcessInfo.processInfo.beginActivity(options: [.userInitiatedAllowingIdleSystemSleep], reason: "Active Time Tracking")
        }
        timerTask?.cancel()
        timerTask = Swift.Task { @MainActor [weak self] in
            while !Swift.Task.isCancelled {
                do {
                    try await Swift.Task.sleep(nanoseconds: 1_000_000_000)
                    self?.tick()
                } catch {
                    break
                }
            }
        }
    }
    
    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
        if let act = activity {
            ProcessInfo.processInfo.endActivity(act)
            activity = nil
        }
    }
    
    private func updateDockBadge() {
        #if os(macOS)
        DispatchQueue.main.async {
            if let timeText = self.formattedTime {
                NSApp.dockTile.badgeLabel = timeText
            } else {
                NSApp.dockTile.badgeLabel = nil
            }
        }
        #endif
    }
    
    private func tick() {
        // Check for idle time (e.g. 15 minutes = 900 seconds)
        #if os(macOS)
        let anyInputType = CGEventType(rawValue: UInt32.max) ?? .leftMouseDown
        let idleTime = CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: anyInputType)
        let idleThreshold: TimeInterval = 900 // 15 minutes
        if idleTime > idleThreshold && (isTaskRunning || pomodoroState == .focus) {
            pauseActiveTask()
            if pomodoroState == .focus {
                pomodoroState = .inactive
                pomodoroTimeRemaining = 0
                pomodoroTargetDate = nil
                #if os(macOS)
                applyStrictFocusMode(enabled: false)
                #endif
            }
            evaluateTimerState()
            
            DispatchQueue.main.async {
                let content = UNMutableNotificationContent()
                content.title = "Inactividad Detectada"
                content.body = "Parece que no has estado en tu computadora por más de 15 minutos. Hemos pausado tu sesión automáticamente."
                content.sound = .default
                let request = UNNotificationRequest(identifier: "idle_alert", content: content, trigger: nil)
                UNUserNotificationCenter.current().add(request)
            }
            return
        }
        #endif
        
        // Update the project array reference to trigger UI updates for the active task duration
        if let pID = activeProjectID, let tID = activeTaskID,
           let pIndex = projects.firstIndex(where: { $0.id == pID }),
           let tIndex = projects[pIndex].tasks.firstIndex(where: { $0.id == tID }) {
            
            // Re-assigning to trigger observation
            let task = projects[pIndex].tasks[tIndex]
            projects[pIndex].tasks[tIndex] = task
        }
        
        
        // Update generic focus time if tracking a pomodoro without an active task
        if pomodoroState == .focus && !isTaskRunning {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy_MM_dd"
            let dateString = formatter.string(from: Date())
            let currentGenericTime = UserDefaults.standard.double(forKey: "generic_focus_\(dateString)")
            UserDefaults.standard.set(currentGenericTime + 1.0, forKey: "generic_focus_\(dateString)")
            updateDailyStats()
        }
        
        if isTaskRunning {
            // todayTotalTime can be recalculated accurately rather than just incremented
            updateDailyStats() 
        }
        
        if pomodoroState == .focus || pomodoroState == .shortBreak || pomodoroState == .longBreak {
            if let target = pomodoroTargetDate {
                pomodoroTimeRemaining = target.timeIntervalSinceNow
            } else {
                pomodoroTargetDate = Date().addingTimeInterval(pomodoroTimeRemaining)
            }
            
            if pomodoroTimeRemaining <= 0 {
                if pomodoroState == .focus {
                    pauseActiveTask() // pause task logging, if any
                    
                    // Incrementar contador de pomodoros diarios
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy_MM_dd"
                    let dateString = formatter.string(from: Date())
                    let count = UserDefaults.standard.integer(forKey: "pomodoros_\(dateString)") + 1
                    UserDefaults.standard.set(count, forKey: "pomodoros_\(dateString)")
                    self.todayPomodoros = count
                    
                    self.updateStreakLogic()
                    
                    pomodoroState = .shortBreak
                    let shortBreakMinutes = UserDefaults.standard.integer(forKey: "pomodoroShortBreakMinutes")
                    let minutes = shortBreakMinutes > 0 ? shortBreakMinutes : 5
                    pomodoroTimeRemaining = TimeInterval(minutes * 60)
                    pomodoroTargetDate = Date().addingTimeInterval(pomodoroTimeRemaining)
                    
                    #if os(macOS)
                    applyStrictFocusMode(enabled: false)
                    #endif
                    
                    evaluateTimerState()
                    SoundManager.playAlert()
                } else {
                    pomodoroState = .inactive
                    pomodoroTimeRemaining = 0
                    pomodoroTargetDate = nil
                    evaluateTimerState()
                    SoundManager.playAlert()
                }
            }
        }
        
        if Date().timeIntervalSince(lastSaveTime) > 60 {
            saveData()
            lastSaveTime = Date()
        }
        
        updateDockBadge()
    }
    
    public func deleteProject(id: UUID) {
        projects.removeAll { $0.id == id }
        if activeProjectID == id { stopActiveTask() }
        saveData()
    }
    
    public func deleteTask(projectID: UUID, taskID: UUID) {
        if let idx = projects.firstIndex(where: { $0.id == projectID }) {
            projects[idx].tasks.removeAll { $0.id == taskID }
            if activeProjectID == projectID && activeTaskID == taskID {
                stopActiveTask()
            }
            saveData()
        }
    }
}
