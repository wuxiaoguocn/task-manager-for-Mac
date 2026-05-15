import SwiftUI

struct StorageView: View {
    let storageInfo: StorageInfo
    
    var body: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: 8) {
                // Header
                HStack {
                    Image(systemName: "externaldrive")
                        .font(.title3)
                        .foregroundStyle(.purple)
                    Text("储存")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(String(format: "%.1f%% 已使用", storageInfo.usagePercent))
                        .font(.title3.bold())
                        .foregroundStyle(.purple)
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
                                    colors: [.purple, storageInfo.usagePercent > 80 ? .red : .purple.opacity(0.5)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * CGFloat(min(storageInfo.usagePercent / 100, 1.0)), height: 8)
                    }
                }
                .frame(height: 8)
                
                // Details
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Label(String(format: "已用 %@", formatBytes(storageInfo.used)), systemImage: "folder")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Label(String(format: "总计 %@", formatBytes(storageInfo.total)), systemImage: "externaldrive")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
