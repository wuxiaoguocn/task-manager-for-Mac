import SwiftUI

struct ContentView: View {
    @EnvironmentObject var monitor: PerformanceMonitor
    @ObservedObject private var settings = AppSettings.shared
    @Environment(\.openSettings) private var openSettingsAction
    
    var body: some View {
        VStack(spacing: 0) {
            // Title Bar
            titleBar
            
            Divider()
                .opacity(0.3)
            
            ScrollView {
                VStack(spacing: 12) {
                    // CPU + Memory row
                    HStack(spacing: 12) {
                        CPUView(cpuInfo: monitor.cpuInfo, history: monitor.cpuHistory)
                            .frame(maxWidth: .infinity)
                        if settings.monitorMemory {
                            MemoryView(memoryInfo: monitor.memoryInfo)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    
                    // Storage + Battery row
                    HStack(spacing: 12) {
                        if settings.monitorStorage {
                            StorageView(storageInfo: monitor.storageInfo)
                                .frame(maxWidth: .infinity)
                        }
                        if settings.monitorBattery {
                            BatteryView(batteryInfo: monitor.batteryInfo)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    
                    // Network
                    if settings.monitorNetwork {
                        NetworkView(networkInfo: monitor.networkInfo)
                    }
                }
                .padding(16)
            }
            
            // Bottom Toolbar
            Divider()
                .opacity(0.3)
            
            bottomToolbar
        }
        .frame(width: 420, height: 520)
        .background(
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea()
        )
        .onAppear {
            // Force the popover window to always be on top
            if let window = NSApp.windows.first(where: { $0.isVisible && $0.level == .popUpMenu }) {
                window.level = .floating
                window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            }
        }
    }
    
    // MARK: - Title Bar
    private var titleBar: some View {
        HStack {
            Image(systemName: "chart.bar.xaxis")
                .font(.title3)
                .foregroundStyle(.blue)
            Text("性能监视器")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Spacer()
            
            // CPU indicator in title bar
            Image(systemName: cpuIconName)
                .foregroundStyle(cpuIconColor)
                .font(.caption)
            Text(String(format: "%.1f%%", monitor.cpuInfo.totalUsage))
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Bottom Toolbar
    private var bottomToolbar: some View {
        HStack(spacing: 0) {
            Button(action: openActivityMonitor) {
                Label("活动监视器", systemImage: "magnifyingglass.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            Spacer()
            
            Button(action: openSettings) {
                Label("设置", systemImage: "gearshape")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            Spacer()
            
            Button(action: quitApp) {
                Label("退出", systemImage: "power")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Helpers
    private var cpuIconName: String {
        let usage = monitor.cpuInfo.totalUsage
        let threshold = AppSettings.shared.cpuWarningThreshold
        if usage >= threshold { return "exclamationmark.triangle" }
        if usage < 25 { return "tortoise" }
        if usage < 50 { return "hare" }
        if usage < 75 { return "flame" }
        return "exclamationmark.triangle"
    }
    
    private var cpuIconColor: Color {
        let usage = monitor.cpuInfo.totalUsage
        let threshold = AppSettings.shared.cpuWarningThreshold
        if usage >= threshold { return .red }
        if usage < 50 { return .green }
        if usage < 75 { return .orange }
        return .red
    }
    
    private func openActivityMonitor() {
        if let url = URL(string: "file:///System/Applications/Utilities/Activity%20Monitor.app") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func openSettings() {
        // Close the popover first by resigning key window status
        if let window = NSApp.windows.first(where: { $0.isVisible && $0.level == .popUpMenu }) {
            window.orderOut(nil)
        }
        // Open settings
        openSettingsAction()
    }
    
    private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

// MARK: - Visual Effect View (NSViewRepresentable)
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        view.isEmphasized = true
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

#Preview {
    ContentView()
        .environmentObject(PerformanceMonitor())
}
