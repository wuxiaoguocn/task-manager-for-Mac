import SwiftUI

struct CPUView: View {
    let cpuInfo: CPUInfo
    let history: [Double]
    @ObservedObject private var settings = AppSettings.shared
    
    var body: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: 8) {
                // Header
                HStack {
                    Image(systemName: "cpu")
                        .font(.title3)
                        .foregroundStyle(.blue)
                    Text("CPU")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(String(format: "%.1f%%", cpuInfo.totalUsage))
                        .font(.title2.bold())
                        .foregroundStyle(.blue)
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
                                    colors: [.blue, cpuInfo.totalUsage >= settings.cpuWarningThreshold ? .red : .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * CGFloat(min(cpuInfo.totalUsage / 100, 1.0)), height: 8)
                    }
                }
                .frame(height: 8)
                
                // CPU History sparkline
                if !history.isEmpty {
                    GeometryReader { geo in
                        Path { path in
                            let maxVal = max(history.max() ?? 100, 1)
                            let stepX = geo.size.width / CGFloat(max(history.count - 1, 1))
                            
                            path.move(to: CGPoint(x: 0, y: geo.size.height * (1 - CGFloat(history[0] / maxVal))))
                            
                            for i in 1..<history.count {
                                let x = CGFloat(i) * stepX
                                let y = geo.size.height * (1 - CGFloat(history[i] / maxVal))
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                        .stroke(
                            LinearGradient(
                                colors: [.blue.opacity(0.6), .blue.opacity(0.3)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1.5
                        )
                    }
                    .frame(height: 30)
                }
                
                // Details
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Label(String(format: "系统 %.1f%%", cpuInfo.system), systemImage: "gearshape")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Label(String(format: "用户 %.1f%%", cpuInfo.user), systemImage: "person")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Label(String(format: "闲置 %.1f%%", cpuInfo.idle), systemImage: "moon")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
        }
    }
}
