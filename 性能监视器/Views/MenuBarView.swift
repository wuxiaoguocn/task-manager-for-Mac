import SwiftUI

struct MenuBarView: View {
    @ObservedObject var monitor: PerformanceMonitor
    @ObservedObject private var settings = AppSettings.shared
    
    var body: some View {
        HStack(spacing: 4) {
            if settings.showMenuBarIcon {
                Image(systemName: cpuIconName)
                    .foregroundStyle(cpuIconColor)
            }
            if settings.showMenuBarPercentage {
                Text(String(format: "%.1f%%", monitor.cpuInfo.totalUsage))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.primary)
            }
            
            // Experimental: Memory usage in menu bar
            if settings.experimentalUnlocked && settings.showMenuBarMemory {
                Text(String(format: "MEM: %.1f%%", monitor.memoryInfo.usagePercent))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.green)
            }
            
            // Experimental: Storage usage in menu bar
            if settings.experimentalUnlocked && settings.showMenuBarStorage {
                Text(String(format: "DISK: %.1f%%", monitor.storageInfo.usagePercent))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.purple)
            }
            
            // Experimental: Battery in menu bar
            if settings.experimentalUnlocked && settings.showMenuBarBattery {
                HStack(spacing: 2) {
                    Image(systemName: batteryIconName)
                        .foregroundStyle(batteryIconColor)
                    Text(String(format: "%.0f%%", monitor.batteryInfo.chargePercent))
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.primary)
                }
            }
            
            // Experimental: Network in menu bar
            if settings.experimentalUnlocked && settings.showMenuBarNetwork {
                HStack(spacing: 2) {
                    Image(systemName: "arrow.up")
                        .font(.system(.caption))
                        .foregroundStyle(.orange)
                    Text(formatSpeed(monitor.networkInfo.uploadSpeed))
                        .font(.system(.caption, design: .monospaced))
                    Image(systemName: "arrow.down")
                        .font(.system(.caption))
                        .foregroundStyle(.blue)
                    Text(formatSpeed(monitor.networkInfo.downloadSpeed))
                        .font(.system(.caption, design: .monospaced))
                }
            }
        }
        .padding(.horizontal, 4)
    }
    
    private var cpuIconName: String {
        let usage = monitor.cpuInfo.totalUsage
        let cpuThreshold = settings.cpuWarningThreshold
        if usage >= cpuThreshold {
            return "exclamationmark.triangle"
        }
        if usage < 25 {
            return "tortoise"
        } else if usage < 50 {
            return "hare"
        } else if usage < 75 {
            return "flame"
        } else {
            return "exclamationmark.triangle"
        }
    }
    
    private var cpuIconColor: Color {
        let usage = monitor.cpuInfo.totalUsage
        let cpuThreshold = settings.cpuWarningThreshold
        if usage >= cpuThreshold {
            return .red
        }
        if usage < 50 {
            return .green
        } else if usage < 75 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var batteryIconName: String {
        let charge = monitor.batteryInfo.chargePercent
        if charge > 75 {
            return "battery.100"
        } else if charge > 50 {
            return "battery.75"
        } else if charge > 25 {
            return "battery.50"
        } else {
            return "battery.25"
        }
    }
    
    private var batteryIconColor: Color {
        let charge = monitor.batteryInfo.chargePercent
        if charge > 50 {
            return .green
        } else if charge > 20 {
            return .orange
        } else {
            return .red
        }
    }
    
    private func formatSpeed(_ speed: Double) -> String {
        if speed < 1024 {
            return String(format: "%.1f B/s", speed)
        } else if speed < 1024 * 1024 {
            return String(format: "%.1f KB/s", speed / 1024)
        } else {
            return String(format: "%.1f MB/s", speed / (1024 * 1024))
        }
    }
}
