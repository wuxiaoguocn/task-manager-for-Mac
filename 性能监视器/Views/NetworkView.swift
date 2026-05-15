import SwiftUI

struct NetworkView: View {
    let networkInfo: NetworkInfo
    
    var body: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: 8) {
                // Header
                HStack {
                    Image(systemName: "network")
                        .font(.title3)
                        .foregroundStyle(.cyan)
                    Text("网络")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Label(
                        networkInfo.isConnected ? "已连接" : "未连接",
                        systemImage: networkInfo.isConnected ? "checkmark.circle.fill" : "xmark.circle.fill"
                    )
                    .font(.caption)
                    .foregroundStyle(networkInfo.isConnected ? .green : .red)
                }
                
                // Network speeds
                HStack(spacing: 20) {
                    // Upload
                    VStack(alignment: .leading, spacing: 2) {
                        Label("上传", systemImage: "arrow.up")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatSpeed(networkInfo.uploadSpeed))
                            .font(.system(.title3, design: .monospaced))
                            .foregroundStyle(.cyan)
                    }
                    
                    // Download
                    VStack(alignment: .leading, spacing: 2) {
                        Label("下载", systemImage: "arrow.down")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatSpeed(networkInfo.downloadSpeed))
                            .font(.system(.title3, design: .monospaced))
                            .foregroundStyle(.cyan)
                    }
                    
                    Spacer()
                }
                
                // IP Address
                if !networkInfo.ipAddress.isEmpty {
                    HStack {
                        Image(systemName: "ipad.and.iphone")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("IP: \(networkInfo.ipAddress)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
        }
    }
    
    private func formatSpeed(_ bytesPerSecond: Double) -> String {
        if bytesPerSecond < 1024 {
            return String(format: "%.1f B/s", bytesPerSecond)
        } else if bytesPerSecond < 1024 * 1024 {
            return String(format: "%.1f KB/s", bytesPerSecond / 1024)
        } else if bytesPerSecond < 1024 * 1024 * 1024 {
            return String(format: "%.1f MB/s", bytesPerSecond / (1024 * 1024))
        } else {
            return String(format: "%.1f GB/s", bytesPerSecond / (1024 * 1024 * 1024))
        }
    }
}
