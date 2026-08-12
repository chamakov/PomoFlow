import Foundation
import AppKit

public struct SoundManager {
    public static func playAlert() {
        let soundName = UserDefaults.standard.string(forKey: "pomodoroAlertSound") ?? "Glass"
        
        Swift.Task {
            for i in 0..<2 {
                for _ in 0..<3 {
                    let sound = NSSound(named: NSSound.Name(soundName))
                    sound?.play()
                    try? await Swift.Task.sleep(nanoseconds: 500_000_000) // 0.5s between beeps
                }
                if i == 0 {
                    try? await Swift.Task.sleep(nanoseconds: 1_000_000_000) // 1s silence
                }
            }
        }
    }
}
