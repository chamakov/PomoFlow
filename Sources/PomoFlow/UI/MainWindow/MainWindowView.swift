import SwiftUI

public struct MainWindowView: View {
    @Environment(PomoFlowStore.self) private var store
    @Environment(\.openWindow) private var openWindow
    
    public init() {}
    
    public var body: some View {
        @Bindable var store = store
        
        NavigationSplitView {
            List(selection: $store.selectedTab) {
                NavigationLink(value: AppScreen.projects) {
                    Label("Projects", systemImage: "folder.fill")
                }
                NavigationLink(value: AppScreen.reports) {
                    Label("Reports", systemImage: "chart.bar.xaxis")
                }
                NavigationLink(value: AppScreen.settings) {
                    Label("Settings", systemImage: "gearshape")
                }
            }
            .navigationTitle("PomoFlow")
        } detail: {
            switch store.selectedTab {
            case .projects:
                ProjectManagerView()
            case .reports:
                ReportsView()
            case .settings:
                SettingsView()
            }
        }
        .frame(minWidth: 700, idealWidth: 800, minHeight: 500, idealHeight: 600)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    openWindow(id: "help")
                }) {
                    Image(systemName: "questionmark.circle")
                }
                .help("Help")
            }
        }
    }
}
