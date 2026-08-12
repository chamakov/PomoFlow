import SwiftUI

public struct TimerPopoverView: View {
    @Environment(PomoFlowStore.self) private var store

    @Environment(\.openWindow) private var openWindow
    @Environment(\.openSettings) private var openSettings
    
    @State private var isEnteringIntent = false
    @State private var intentText = ""

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("PomoFlow")
                    .font(.headline)
                Spacer()
                
                Button(action: {
                    store.selectedTab = .projects
                    NSApp.keyWindow?.close()
                    WindowManager.shared.showDockIcon()
                    NSApp.activate(ignoringOtherApps: true)
                    openWindow(id: "main")
                }) {
                    Image(systemName: "folder.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .hoverEffect()
                .help("Projects")
                
                Button(action: {
                    store.selectedTab = .reports
                    NSApp.keyWindow?.close()
                    WindowManager.shared.showDockIcon()
                    NSApp.activate(ignoringOtherApps: true)
                    openWindow(id: "main")
                }) {
                    Image(systemName: "chart.bar.xaxis")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .hoverEffect()
                .help("Reports")
                
                Button(action: {
                    NSApp.keyWindow?.close()
                    WindowManager.shared.showDockIcon()
                    NSApp.activate(ignoringOtherApps: true)
                    if #available(macOS 14.0, *) {
                        openSettings()
                    } else {
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    }
                }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .hoverEffect()
                .help("Settings")
                
                Button(action: {
                    NSApp.keyWindow?.close()
                    WindowManager.shared.showDockIcon()
                    NSApp.activate(ignoringOtherApps: true)
                    openWindow(id: "help")
                }) {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .hoverEffect()
                .help("Help")
                
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Image(systemName: "power")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .hoverEffect()
                .help("Quit")
            }
            .padding()
            
            Divider().opacity(0.5)
            
            // Timer Display
            VStack(spacing: 24) {
                if store.pomodoroState != .inactive {
                    Text(pomodoroStateText)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(stateColor)
                        .padding(.top, 24)
                } else {
                    Text(store.isTaskRunning ? "TRACKING TIME" : (store.activeTaskID != nil ? "PAUSED" : "READY"))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(store.isTaskRunning ? .green : .secondary)
                        .padding(.top, 24)
                }
                
                ZStack {
                    Circle()
                        .stroke(Color.secondary.opacity(0.1), lineWidth: 12)
                        .frame(width: 160, height: 160)
                    
                    if store.pomodoroState != .inactive {
                        Circle()
                            .trim(from: 0, to: pomodoroProgress)
                            .stroke(stateColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .frame(width: 160, height: 160)
                            .rotationEffect(.degrees(-90))
                            .shadow(color: stateColor.opacity(0.4), radius: 10, x: 0, y: 0)
                            .animation(.linear(duration: 1), value: store.pomodoroTimeRemaining)
                    } else if store.isTaskRunning {
                        Circle()
                            .stroke(Color.green.opacity(0.7), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .frame(width: 160, height: 160)
                            .shadow(color: Color.green.opacity(0.5), radius: 10, x: 0, y: 0)
                    }
                    
                    Text(displayTimeString)
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 8)
                
                // Controls
                if isEnteringIntent {
                    VStack(spacing: 12) {
                        TextField("What are you working on?", text: $intentText)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 13))
                        
                        HStack {
                            Button("Cancel") {
                                isEnteringIntent = false
                            }
                            .buttonStyle(.plain)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button("Start") {
                                store.currentIntent = intentText.isEmpty ? nil : intentText
                                store.togglePomodoro()
                                isEnteringIntent = false
                            }
                            .buttonStyle(.plain)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                } else {
                    HStack(spacing: 32) {
                        if store.activeTaskID != nil {
                            Button(action: {
                                if store.isTaskRunning {
                                    store.pauseActiveTask()
                                } else {
                                    store.resumeActiveTask()
                                }
                            }) {
                                Image(systemName: store.isTaskRunning ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(store.isTaskRunning ? .orange : .green)
                                    .shadow(color: store.isTaskRunning ? Color.orange.opacity(0.3) : Color.green.opacity(0.3), radius: 5, x: 0, y: 2)
                            }
                            .buttonStyle(.plain)
                            .hoverEffect()
                            
                            Button(action: {
                                store.stopActiveTask()
                            }) {
                                Image(systemName: "stop.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(.red)
                                    .shadow(color: Color.red.opacity(0.3), radius: 5, x: 0, y: 2)
                            }
                            .buttonStyle(.plain)
                            .hoverEffect()
                        }
                        
                        Button(action: {
                            store.togglePomodoro()
                        }) {
                            VStack(spacing: 6) {
                                Image(systemName: "timer")
                                    .font(.system(size: 26))
                                Text("Pomodoro")
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .foregroundColor(store.pomodoroState == .inactive ? .secondary : .primary)
                        }
                        .buttonStyle(.plain)
                        .hoverEffect()
                        .disabled(store.activeTaskID != nil && !store.isTaskRunning && store.pomodoroState == .inactive)
                        .opacity(store.activeTaskID != nil && !store.isTaskRunning && store.pomodoroState == .inactive ? 0.5 : 1.0)
                        .padding(.leading, store.activeTaskID != nil ? 12 : 0)
                    }
                    .padding(.bottom, 24)
                }
            }
            
            Divider().opacity(0.5)
            
            // Active Task Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Current Task")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                if let activeProjectID = store.activeProjectID,
                   let activeTaskID = store.activeTaskID,
                   let project = store.projects.first(where: { $0.id == activeProjectID }),
                   let task = project.tasks.first(where: { $0.id == activeTaskID }) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.title)
                            .font(.body)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        Text(project.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                } else {
                    Text("No task selected")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Menu {
                    ForEach(store.projects) { project in
                        Menu(project.name) {
                            ForEach(project.tasks) { task in
                                Button(task.title) {
                                    store.startTask(projectID: project.id, taskID: task.id)
                                }
                            }
                        }
                    }
                } label: {
                    Label("Switch Task...", systemImage: "arrow.left.arrow.right")
                        .font(.caption)
                }
                .menuStyle(.borderlessButton)
                .padding(.top, 4)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider().opacity(0.5)
            
            // Daily Progress Section
            HStack(spacing: 20) {
                let hoursGoal: TimeInterval = 6 * 3600
                let pomodoroGoal: Double = 8
                
                DualProgressRingView(
                    outerProgress: store.todayTotalTime / hoursGoal,
                    innerProgress: Double(store.todayPomodoros) / pomodoroGoal,
                    outerColor: .green,
                    innerColor: .blue,
                    size: 40
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Circle().fill(.green).frame(width: 6, height: 6)
                            Text("\(String(format: "%.1f", store.todayTotalTime / 3600))h")
                                .font(.caption2)
                                .fontWeight(.bold)
                        }
                        HStack(spacing: 4) {
                            Circle().fill(.blue).frame(width: 6, height: 6)
                            Text("\(store.todayPomodoros) / \(Int(pomodoroGoal))")
                                .font(.caption2)
                                .fontWeight(.bold)
                        }
                    }
                }
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(store.currentStreak)")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 300)
        .background(.ultraThinMaterial)
    }
    
    private var stateColor: Color {
        switch store.pomodoroState {
        case .inactive: return .secondary
        case .focus: return .red
        case .shortBreak: return .green
        case .longBreak: return .blue
        }
    }
    
    private var pomodoroStateText: String {
        switch store.pomodoroState {
        case .inactive: return "READY"
        case .focus:
            if store.activeTaskID != nil && !store.isTaskRunning {
                return "FOCUS (PAUSED)"
            }
            return "FOCUS TIME"
        case .shortBreak: return "SHORT BREAK"
        case .longBreak: return "LONG BREAK"
        }
    }
    
    private var pomodoroProgress: CGFloat {
        let total: TimeInterval
        switch store.pomodoroState {
        case .focus: total = 25 * 60
        case .shortBreak: total = 5 * 60
        case .longBreak: total = 15 * 60
        case .inactive: total = 1
        }
        return CGFloat(store.pomodoroTimeRemaining / total)
    }
    
    private var displayTimeString: String {
        if store.pomodoroState != .inactive {
            return timeString(from: store.pomodoroTimeRemaining)
        } else if let activeProjectID = store.activeProjectID,
                  let activeTaskID = store.activeTaskID,
                  let project = store.projects.first(where: { $0.id == activeProjectID }),
                  let task = project.tasks.first(where: { $0.id == activeTaskID }) {
            return timeString(from: task.totalTimeSpent)
        } else {
            return "00:00"
        }
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
}

struct HoverEffect: ViewModifier {
    @State private var isHovered = false
    
    func body(content: Content) -> some View {
        content
            .padding(6)
            .background(isHovered ? Color.secondary.opacity(0.15) : Color.clear)
            .cornerRadius(8)
            .onHover { hovering in
                isHovered = hovering
            }
            .animation(.easeInOut(duration: 0.1), value: isHovered)
    }
}

extension View {
    func hoverEffect() -> some View {
        self.modifier(HoverEffect())
    }
}
