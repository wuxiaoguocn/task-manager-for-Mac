import SwiftUI

struct BatteryView: View {
    let batteryInfo: BatteryInfo
    @ObservedObject private var settings = AppSettings.shared
    
    var body: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: 8) {
                // Header
                HStack {
                    Image(systemName: batteryIcon)
                        .font(.title3)
                        .foregroundStyle(batteryColor)
                    Text("电池")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(String(format: "%.1f%%", batteryInfo.chargePercent))
                        .font(.title2.bold())
                        .foregroundStyle(batteryColor)
                }
                
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.ultraThinMaterial)
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [batteryColor, batteryColor.opacity(0.5)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * CGFloat(min(batteryInfo.chargePercent / 100, 1.0)), height: 8)
                    }
                }
                .frame(height: 8)
                
                // Details
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        if batteryInfo.isConnected {
                            Label(String(format: "电源 %.0fW", batteryInfo.powerWatts), systemImage: "powerplug")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Label(String(format: "循环 %d", batteryInfo.cycleCount), systemImage: "arrow.triangle.2.circlepath")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Label(formattedTemperature, systemImage: "thermometer")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
        }
    }
    
    private var formattedTemperature: String {
        let temp = batteryInfo.temperature
        switch settings.temperatureUnit {
        case .celsius:
            return String(format: "温度 %.1f°C", temp)
        case .fahrenheit:
            let f = temp * 9.0 / 5.0 + 32.0
            return String(format: "温度 %.1f°F", f)
        }
    }
    
    private var batteryIcon: String {
        if batteryInfo.isCharging {
            return "battery.100.bolt"
        }
        let pct = batteryInfo.chargePercent
        if pct > 75 { return "battery.100" }
        if pct > 50 { return "battery.75" }
        if pct > 25 { return "battery.50" }
        if pct > 10 { return "battery.25" }
        return "battery.0"
    }
    
    private var batteryColor: Color {
        if batteryInfo.isCharging { return .green }
        let pct = batteryInfo.chargePercent
        if pct > 20 { return .green }
        if pct > 10 { return .yellow }
        return .red
    }
}
