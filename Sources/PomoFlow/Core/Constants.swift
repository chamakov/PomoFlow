import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleTimer = Self("toggleTimer", default: .init(.p, modifiers: [.command, .option]))
    static let togglePomodoro = Self("togglePomodoro", default: .init(.o, modifiers: [.command, .option]))
    static let showApp = Self("showApp", default: .init(.t, modifiers: [.command, .option]))
}
