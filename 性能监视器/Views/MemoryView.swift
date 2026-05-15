import SwiftUI

struct MemoryView: View {
    let memoryInfo: MemoryInfo
    @ObservedObject private var settings = AppSettings.shared
    
    var body: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: 8) {
                // Header
                HStack {
                    Image(systemName: "memorychip")
                        .font(.title3)
                        .foregroundStyle(.green)
                    Text("内存")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(String(format: "%.1f%%", memoryInfo.usagePercent))
                        .font(.title2.bold())
                        .foregroundStyle(.green)
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
                                    colors: [.green, memoryInfo.usagePercent >= settings.memoryWarningThreshold ? .red : .yellow],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * CGFloat(min(memoryInfo.usagePercent / 100, 1.0)), height: 8)
                    }
                }
                .frame(height: 8)
                
                // Details
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Label(String(format: "压力 %d%%", memoryInfo.pressure), systemImage: "gauge.medium")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Label(String(format: "App %@", formatBytes(memoryInfo.appMemory)), systemImage: "app")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Label(String(format: "联动 %@", formatBytes(memoryInfo.wiredMemory)), systemImage: "link")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
        }
    }
    
    private func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(bytes))
    }
}
