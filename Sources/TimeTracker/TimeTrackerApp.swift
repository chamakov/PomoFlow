import SwiftUI
import KeyboardShortcuts
import UserNotifications
@MainActor
class WindowManager: NSObject {
    static let shared = WindowManager()
    private var isObserving = false
    
    func startObserving() {
        guard !isObserving else { return }
        isObserving = true
        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: nil, queue: .main) { _ in
            Swift.Task { @MainActor in
                let visibleWindows = NSApplication.shared.windows.filter { 
                    $0.isVisible && 
                    $0.className != "NSStatusBarWindow" && 
                    $0.className != "_NSPopoverWindow"
                }
                if visibleWindows.isEmpty {
                    NSApp.setActivationPolicy(.accessory)
                }
            }
        }
    }
    
    func showDockIcon() {
        if NSApp.activationPolicy() != .regular {
            NSApp.setActivationPolicy(.regular)
        }
    }
}

@main
struct TimeTrackerApp: App {
    @State private var store = TimeTrackerStore()
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        MenuBarExtra {
            TimerPopoverView()
                .environment(store)
                .task {
                    do {
                        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
                    } catch {}
                    await store.loadData()
                    KeyboardShortcuts.onKeyDown(for: .toggleTimer) {
                        if store.isTaskRunning {
                            store.pauseActiveTask()
                        } else if store.activeProjectID != nil && store.activeTaskID != nil {
                            store.resumeActiveTask()
                        } else {
                            store.togglePomodoro()
                        }
                    }
                    KeyboardShortcuts.onKeyDown(for: .togglePomodoro) {
                        store.togglePomodoro()
                    }
                    KeyboardShortcuts.onKeyDown(for: .showApp) {
                        NSApp.activate(ignoringOtherApps: true)
                        openWindow(id: "main")
                    }
                }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "timer.circle.fill")
                
                if let timeText = store.formattedTime {
                    Text(timeText)
                        .monospacedDigit()
                }
            }
        }
        .menuBarExtraStyle(.window)

        Window("Time Tracker", id: "main") {
            MainWindowView()
                .environment(store)
        }
        
        #if os(macOS)
        Settings {
            SettingsView()
        }
        
        Window("Time Tracker Help", id: "help") {
            HelpView()
        }
        .commands {
            CommandGroup(replacing: .help) {
                Button("Time Tracker Help") {
                    openWindow(id: "help")
                }
            }
        }
        #endif
    }
    
    init() {
        WindowManager.shared.startObserving()
    }
}
