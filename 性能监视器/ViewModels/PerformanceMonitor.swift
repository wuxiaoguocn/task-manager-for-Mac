import Foundation
import Combine
import UserNotifications

class PerformanceMonitor: ObservableObject {
    @Published var cpuInfo = CPUInfo()
    @Published var memoryInfo = MemoryInfo()
    @Published var storageInfo = StorageInfo()
    @Published var batteryInfo = BatteryInfo()
    @Published var networkInfo = NetworkInfo()
    
    @Published var cpuHistory: [Double] = []
    
    // Warning state tracking (to avoid repeated notifications)
    private var lastCPUWarningTime: Date?
    private var lastMemoryWarningTime: Date?
    
    private var timer: Timer?
    private var settingsObserver: NSObjectProtocol?
    
    init() {
        requestNotificationPermission()
        startMonitoring()
        observeSettings()
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func startMonitoring() {
        // Initial fetch
        fetchAll()
        
        // Timer for periodic updates
        restartTimer()
    }
    
    private func restartTimer() {
        timer?.invalidate()
        let interval = AppSettings.shared.refreshInterval
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.fetchAll()
        }
    }
    
    private func observeSettings() {
        settingsObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.restartTimer()
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    func fetchAll() {
        // Fetch CPU
        let cpu = SystemInfo.getCPUInfo()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.cpuInfo = cpu
            self.cpuHistory.append(cpu.totalUsage)
            if self.cpuHistory.count > 60 {
                self.cpuHistory.removeFirst()
            }
            // Check CPU warning
            self.checkCPUWarning(usage: cpu.totalUsage)
        }
        
        // Fetch other metrics
        DispatchQueue.global(qos: .background).async { [weak self] in
            let memory = SystemInfo.getMemoryInfo()
            let storage = SystemInfo.getStorageInfo()
            let battery = SystemInfo.getBatteryInfo()
            let network = SystemInfo.getNetworkInfo()
            
            DispatchQueue.main.async {
                self?.memoryInfo = memory
                self?.storageInfo = storage
                self?.batteryInfo = battery
                self?.networkInfo = network
                // Check memory warning
                self?.checkMemoryWarning(usage: memory.usagePercent)
            }
        }
    }
    
    // MARK: - Warning Checks
    private func canSendWarning(lastWarning: Date?) -> Bool {
        let interval = AppSettings.shared.warningInterval * 60 // 转换为秒
        guard let last = lastWarning else { return true }
        return Date().timeIntervalSince(last) >= interval
    }
    
    private func checkCPUWarning(usage: Double) {
        let threshold = AppSettings.shared.cpuWarningThreshold
        if usage >= threshold && canSendWarning(lastWarning: lastCPUWarningTime) {
            lastCPUWarningTime = Date()
            sendNotification(
                title: "CPU 使用率过高",
                body: String(format: "当前 CPU 使用率 %.1f%%，超过警告阈值 %.0f%%", usage, threshold)
            )
        }
    }
    
    private func checkMemoryWarning(usage: Double) {
        let threshold = AppSettings.shared.memoryWarningThreshold
        if usage >= threshold && canSendWarning(lastWarning: lastMemoryWarningTime) {
            lastMemoryWarningTime = Date()
            sendNotification(
                title: "内存使用率过高",
                body: String(format: "当前内存使用率 %.1f%%，超过警告阈值 %.0f%%", usage, threshold)
            )
        }
    }
    
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error)")
            }
        }
    }
    
    deinit {
        stopMonitoring()
        if let observer = settingsObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
