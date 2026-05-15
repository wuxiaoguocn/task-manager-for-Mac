import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @ObservedObject var settings = AppSettings.shared
    @State private var selectedTab: SettingsTab = .general
    @State private var showExperimentalUnlock = false
    
    enum SettingsTab: String, CaseIterable {
        case general = "常规"
        case systemInfo = "系统信息"
        case experimental = "实验性功能"
        
        var icon: String {
            switch self {
            case .general: return "gearshape"
            case .systemInfo: return "desktopcomputer"
            case .experimental: return "flask"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            sidebarView
            
            Divider()
                .opacity(0.3)
            
            // Content
            contentView
        }
        .frame(width: 520, height: 400)
        .background(
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea()
        )
        .onAppear {
            // Force the settings window to always be on top
            if let window = NSApp.windows.first(where: { $0.isVisible && $0.title == "设置" }) {
                window.level = .floating
                window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            }
        }
    }
    
    // MARK: - Sidebar
    private var sidebarView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Window controls placeholder + title
            HStack {
                Circle().fill(.red.opacity(0.8)).frame(width: 10, height: 10)
                Circle().fill(.yellow.opacity(0.8)).frame(width: 10, height: 10)
                Circle().fill(.green.opacity(0.8)).frame(width: 10, height: 10)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Text("系统信息")
                .font(.title2.bold())
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            
            // Sidebar tabs
            VStack(spacing: 2) {
                ForEach(SettingsTab.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: tab.icon)
                                .font(.title3)
                                .frame(width: 24)
                            Text(tab.rawValue)
                                .font(.body)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedTab == tab ? Color.accentColor.opacity(0.15) : .clear)
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            
            Spacer()
        }
        .frame(width: 160)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Content
    @ViewBuilder
    private var contentView: some View {
        switch selectedTab {
        case .general:
            generalSettingsView
        case .systemInfo:
            systemInfoSettingsView
        case .experimental:
            experimentalSettingsView
        }
    }
    
    // MARK: - General Settings
    private var generalSettingsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Display Options
                settingsGroupBox("显示选项") {
                    Toggle(isOn: $settings.showMenuBarIcon) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("菜单栏图标")
                                .font(.body)
                            Text("在菜单栏显示 CPU 状态图标")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Toggle(isOn: $settings.showMenuBarPercentage) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("CPU 百分比")
                                .font(.body)
                            Text("在菜单栏显示 CPU 使用率百分比")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // Refresh Rate
                settingsGroupBox("刷新频率") {
                    HStack {
                        Text("数据刷新间隔")
                        Spacer()
                        Picker("", selection: $settings.refreshInterval) {
                            Text("1 秒").tag(1.0)
                            Text("2 秒").tag(2.0)
                            Text("3 秒").tag(3.0)
                            Text("5 秒").tag(5.0)
                            Text("10 秒").tag(10.0)
                        }
                        .frame(width: 100)
                    }
                }
                
                // Temperature Unit
                settingsGroupBox("温度单位") {
                    HStack {
                        Text("温度显示单位")
                        Spacer()
                        Picker("", selection: $settings.temperatureUnit) {
                            ForEach(AppSettings.TemperatureUnit.allCases, id: \.self) { unit in
                                Text(unit.displayName).tag(unit)
                            }
                        }
                        .frame(width: 140)
                    }
                }
                
                // Launch at Login
                settingsGroupBox("启动") {
                    Toggle(isOn: $settings.launchAtLogin) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("登录时启动")
                                .font(.body)
                            Text("开机登录时自动启动性能监视器")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onChange(of: settings.launchAtLogin) { _, newValue in
                        toggleLaunchAtLogin(enabled: newValue)
                    }
                }
                
                // Warning Thresholds
                settingsGroupBox("警告阈值") {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("CPU 警告阈值")
                                Spacer()
                                Text(String(format: "%.0f%%", settings.cpuWarningThreshold))
                                    .foregroundStyle(.secondary)
                                    .monospacedDigit()
                            }
                            Slider(value: $settings.cpuWarningThreshold, in: 50...95, step: 5)
                                .tint(.orange)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("内存警告阈值")
                                Spacer()
                                Text(String(format: "%.0f%%", settings.memoryWarningThreshold))
                                    .foregroundStyle(.secondary)
                                    .monospacedDigit()
                            }
                            Slider(value: $settings.memoryWarningThreshold, in: 50...95, step: 5)
                                .tint(.orange)
                        }
                        
                        Divider()
                            .opacity(0.3)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("警告间隔")
                                Spacer()
                                if settings.warningInterval < 1 {
                                    Text("每次检测")
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text(String(format: "%.0f 分钟", settings.warningInterval))
                                        .foregroundStyle(.secondary)
                                        .monospacedDigit()
                                }
                            }
                            Slider(value: $settings.warningInterval, in: 0...60, step: 1)
                                .tint(.orange)
                            Text("超过阈值后，至少间隔设定时间才会再次发送通知")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
            .padding(16)
        }
    }
    
    // MARK: - System Info Settings
    private var systemInfoSettingsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Monitoring section header
                Text("监测")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 4)
                
                // Monitoring toggles
                VStack(spacing: 0) {
                    monitoringRow(icon: "memorychip", title: "内存性能", isOn: $settings.monitorMemory)
                    Divider().padding(.leading, 44)
                    monitoringRow(icon: "externaldrive", title: "存储容量", isOn: $settings.monitorStorage)
                    Divider().padding(.leading, 44)
                    monitoringRow(icon: "battery.100", title: "电池状态", isOn: $settings.monitorBattery)
                    Divider().padding(.leading, 44)
                    monitoringRow(icon: "network", title: "网络连接", isOn: $settings.monitorNetwork)
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.white.opacity(0.1), lineWidth: 0.5)
                )
                
                // Experimental section header
                Text("实验性功能")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 4)
                    .padding(.top, 8)
                
                // Experimental toggles
                VStack(spacing: 0) {
                    monitoringRow(icon: "info.circle", title: "系统信息栏", isOn: $settings.showSystemInfoBar)
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.white.opacity(0.1), lineWidth: 0.5)
                )
            }
            .padding(16)
        }
    }
    
    // MARK: - Experimental Settings
    private var experimentalSettingsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if !settings.experimentalUnlocked {
                    // Locked state
                    VStack(spacing: 16) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.purple)
                        
                        Text("实验性功能已锁定")
                            .font(.title3.bold())
                        
                        Text("此功能需要验证才能开启")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Button(action: { showExperimentalUnlock = true }) {
                            Text("解锁实验性功能")
                                .font(.headline)
                                .frame(width: 160)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.purple)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .sheet(isPresented: $showExperimentalUnlock) {
                        ExperimentalUnlockView(isUnlocked: $settings.experimentalUnlocked)
                    }
                } else {
                    // Unlocked state - show experimental options
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                            Text("实验性功能已启用")
                                .font(.headline)
                                .foregroundStyle(.red)
                        }
                        
                        Text("这些功能可能会导致系统和软件崩溃，请谨慎使用")
                            .font(.caption)
                            .foregroundStyle(.red)
                        
                        Text("⚠️ 不建议刘海屏用户启用")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.red.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.red.opacity(0.3), lineWidth: 0.5)
                    )
                    
                    // Menu Bar Customization
                    settingsGroupBox("菜单栏自定义显示") {
                        Toggle(isOn: $settings.showMenuBarMemory) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("内存占用率")
                                    .font(.body)
                                Text("在菜单栏显示内存使用率")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Toggle(isOn: $settings.showMenuBarStorage) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("磁盘占用率")
                                    .font(.body)
                                Text("在菜单栏显示磁盘使用率")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Toggle(isOn: $settings.showMenuBarBattery) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("电池电量")
                                    .font(.body)
                                Text("在菜单栏显示电池电量百分比")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Toggle(isOn: $settings.showMenuBarNetwork) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("网络详细信息")
                                    .font(.body)
                                Text("在菜单栏显示网络上传/下载速度")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    // Lock button
                    Button(action: {
                        settings.experimentalUnlocked = false
                    }) {
                        HStack {
                            Image(systemName: "lock")
                            Text("锁定实验性功能")
                        }
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
            }
            .padding(16)
        }
    }
    
    // MARK: - Reusable Components
    private func settingsGroupBox(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.horizontal, 4)
            
            VStack(alignment: .leading, spacing: 10) {
                content()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.white.opacity(0.1), lineWidth: 0.5)
            )
        }
    }
    
    private func monitoringRow(icon: String, title: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .toggleStyle(.switch)
                .controlSize(.small)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
    
    // MARK: - Helper
    private func toggleLaunchAtLogin(enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to \(enabled ? "enable" : "disable") launch at login: \(error)")
            }
        }
    }
}

#Preview {
    SettingsView()
}
