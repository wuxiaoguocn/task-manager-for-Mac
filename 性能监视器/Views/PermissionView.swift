import SwiftUI
import UserNotifications

struct PermissionView: View {
    var onClose: (() -> Void)?
    @State private var notificationGranted = false
    @State private var isRequesting = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Title area
            VStack(spacing: 8) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 40))
                    .foregroundStyle(.blue)
                    .padding(.bottom, 4)
                
                Text("欢迎使用性能监视器")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                
                Text("需要授予以下权限以正常使用所有功能")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 32)
            .padding(.bottom, 24)
            
            // Permission items
            VStack(spacing: 12) {
                permissionRow(
                    icon: "bell.badge.fill",
                    iconColor: .orange,
                    title: "通知",
                    description: "当 CPU 或内存使用率超过阈值时发送警告",
                    isGranted: $notificationGranted
                )
                
                permissionRow(
                    icon: "cpu",
                    iconColor: .blue,
                    title: "CPU 使用率",
                    description: "监控系统 CPU 使用情况",
                    isGranted: .constant(true)
                )
                
                permissionRow(
                    icon: "memorychip",
                    iconColor: .green,
                    title: "内存使用率",
                    description: "监控系统内存使用情况",
                    isGranted: .constant(true)
                )
                
                permissionRow(
                    icon: "externaldrive",
                    iconColor: .purple,
                    title: "存储容量",
                    description: "监控磁盘存储使用情况",
                    isGranted: .constant(true)
                )
                
                permissionRow(
                    icon: "battery.100",
                    iconColor: .mint,
                    title: "电池状态",
                    description: "监控电池电量、温度和循环次数",
                    isGranted: .constant(true)
                )
                
                permissionRow(
                    icon: "network",
                    iconColor: .indigo,
                    title: "网络状态",
                    description: "监控网络上传下载速度",
                    isGranted: .constant(true)
                )
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // Continue button
            VStack(spacing: 8) {
                Button(action: requestNotificationPermission) {
                    HStack {
                        if isRequesting {
                            ProgressView()
                                .scaleEffect(0.8)
                                .frame(width: 16, height: 16)
                        }
                        Text("开始使用")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isRequesting)
                .padding(.horizontal, 32)
                
                Button(action: closeWindow) {
                    Text("稍后设置")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 8)
            }
            .padding(.bottom, 24)
        }
        .frame(width: 380, height: 480)
        .background(
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea()
        )
    }
    
    private func permissionRow(icon: String, iconColor: Color, title: String, description: String, isGranted: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(iconColor)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: isGranted.wrappedValue ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(isGranted.wrappedValue ? Color.green : Color.gray.opacity(0.4))
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
    
    private func closeWindow() {
        if let window = NSApp.windows.first(where: { $0.isVisible && $0.title == "权限确认" }) {
            window.close()
        }
        onClose?()
    }
    
    private func requestNotificationPermission() {
        isRequesting = true
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                notificationGranted = granted
                isRequesting = false
                // Small delay to show the checkmark animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    closeWindow()
                }
            }
        }
    }
}

#Preview {
    PermissionView()
}
