import Foundation
#if os(macOS)
import AppKit

public struct FocusModeManager {
    public static func enableDoNotDisturb() {
        // En macOS moderno no hay una API pública directa.
        // La mejor manera programática sin Shortcuts es intentar invocar
        // el atajo si el usuario lo tiene usando la API Process.
        
        DispatchQueue.global(qos: .background).async {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
            process.arguments = ["run", "Turn On Do Not Disturb"]
            
            do {
                try process.run()
                process.waitUntilExit()
            } catch {
                print("Error enabling Focus Mode via shortcuts: \(error)")
            }
        }
    }
}
#endif
