import SwiftUI
import KeyboardShortcuts

public struct SettingsView: View {
    @AppStorage("pomodoroFocusMinutes") private var pomodoroFocusMinutes: Int = 25
    @AppStorage("pomodoroShortBreakMinutes") private var pomodoroShortBreakMinutes: Int = 5
    @AppStorage("pomodoroLongBreakMinutes") private var pomodoroLongBreakMinutes: Int = 15
    @AppStorage("pomodoroAlertSound") private var pomodoroAlertSound: String = "Glass"
    
    private let availableSounds = ["Basso", "Blow", "Bottle", "Frog", "Funk", "Glass", "Hero", "Morse", "Ping", "Pop", "Purr", "Sosumi", "Submarine", "Tink"]
    
    public init() {}
    
    public var body: some View {
        TabView {
            GeneralSettingsView(
                pomodoroFocusMinutes: $pomodoroFocusMinutes,
                pomodoroShortBreakMinutes: $pomodoroShortBreakMinutes,
                pomodoroLongBreakMinutes: $pomodoroLongBreakMinutes,
                pomodoroAlertSound: $pomodoroAlertSound,
                availableSounds: availableSounds
            )
            .tabItem {
                Label("General", systemImage: "gearshape")
            }
            
            ShortcutsSettingsView()
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }
        }
        .frame(width: 450, height: 420)
    }
}

struct GeneralSettingsView: View {
    @Binding var pomodoroFocusMinutes: Int
    @Binding var pomodoroShortBreakMinutes: Int
    @Binding var pomodoroLongBreakMinutes: Int
    @Binding var pomodoroAlertSound: String
    let availableSounds: [String]
    @AppStorage("strictFocusMode") private var strictFocusMode: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Timer Durations Card
                SettingsCard(title: "Timer Durations", icon: "timer") {
                    VStack(spacing: 12) {
                        SettingStepperRow(title: "Focus Time", icon: "brain.head.profile", value: $pomodoroFocusMinutes, range: 1...90, unit: "min", color: .red)
                        Divider().padding(.leading, 32)
                        SettingStepperRow(title: "Short Break", icon: "cup.and.saucer.fill", value: $pomodoroShortBreakMinutes, range: 1...30, unit: "min", color: .green)
                        Divider().padding(.leading, 32)
                        SettingStepperRow(title: "Long Break", icon: "bed.double.fill", value: $pomodoroLongBreakMinutes, range: 1...60, unit: "min", color: .blue)
                    }
                }
                
                // Notifications Card
                SettingsCard(title: "Notifications", icon: "bell.badge.fill") {
                    HStack {
                        Label {
                            Text("Alert Sound")
                                .font(.body)
                        } icon: {
                            Image(systemName: "speaker.wave.3.fill")
                                .foregroundColor(.orange)
                        }
                        
                        Spacer()
                        
                        Picker("", selection: $pomodoroAlertSound) {
                            ForEach(availableSounds, id: \.self) { sound in
                                Text(sound).tag(sound)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 120)
                        .onChange(of: pomodoroAlertSound) { _, newValue in
                            NSSound(named: NSSound.Name(newValue))?.play()
                        }
                    }
                }
                
                // Advanced Card
                SettingsCard(title: "Advanced", icon: "gearshape.fill") {
                    Toggle(isOn: $strictFocusMode) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Strict Focus Mode")
                                .font(.body)
                            Text("Hides all other apps when a Pomodoro starts")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                }
            }
            .padding(24)
        }
    }
}

struct ShortcutsSettingsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SettingsCard(title: "Global Shortcuts", icon: "keyboard") {
                    Form {
                        KeyboardShortcuts.Recorder("Toggle Timer (Play/Pause)", name: .toggleTimer)
                        KeyboardShortcuts.Recorder("Toggle Pomodoro", name: .togglePomodoro)
                        KeyboardShortcuts.Recorder("Show App", name: .showApp)
                    }
                }
            }
            .padding(24)
        }
    }
}

struct SettingsCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
            
            VStack(alignment: .leading, spacing: 0) {
                content
                    .padding(16)
            }
            .background(.regularMaterial)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
            )
        }
    }
}

struct SettingStepperRow: View {
    let title: String
    let icon: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let unit: String
    let color: Color
    
    var body: some View {
        HStack {
            Label {
                Text(title)
                    .font(.body)
            } icon: {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 20)
            }
            
            Spacer()
            
            Text("\(value) \(unit)")
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .trailing)
            
            Stepper("", value: $value, in: range)
                .labelsHidden()
        }
        .padding(.vertical, 4)
    }
}
