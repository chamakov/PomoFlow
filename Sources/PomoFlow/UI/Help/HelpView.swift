import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("PomoFlow Help")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Group {
                    Text("How to use PomoFlow")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("1. Use the menu bar icon to quickly start or stop tasks.")
                    Text("2. Open the main window from the menu bar to manage projects and tasks.")
                    Text("3. Add projects and their hourly rates.")
                    Text("4. View your total earnings and time spent in the Reports tab.")
                    Text("5. Set up global keyboard shortcuts in the Preferences.")
                }
                
                Group {
                    Text("Pomodoro Technique")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("The app uses the Pomodoro technique to help you focus. Work for a set amount of time (usually 25 minutes), then take a short break.")
                }
                
                Spacer()
            }
            .padding()
        }
        .frame(minWidth: 400, minHeight: 300)
    }
}
