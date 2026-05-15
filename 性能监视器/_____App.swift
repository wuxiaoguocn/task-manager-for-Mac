import SwiftUI

@main
struct PerformanceMonitorApp: App {
    @StateObject private var monitor = PerformanceMonitor()
    
    var body: some Scene {
        // Menu Bar Extra (main interface)
        MenuBarExtra {
            ContentView()
                .environmentObject(monitor)
        } label: {
            MenuBarView(monitor: monitor)
        }
        .menuBarExtraStyle(.window)
        
        // Settings window
        Settings {
            SettingsView()
        }
    }
}
