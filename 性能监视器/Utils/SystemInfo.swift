import Foundation
import IOKit
import IOKit.ps
import Darwin

// MARK: - CPU Info
struct CPUInfo {
    var system: Double = 0
    var user: Double = 0
    var idle: Double = 0
    var totalUsage: Double {
        return system + user
    }
}

// MARK: - Memory Info
struct MemoryInfo {
    var total: UInt64 = 0
    var used: UInt64 = 0
    var appMemory: UInt64 = 0
    var wiredMemory: UInt64 = 0
    var compressed: UInt64 = 0
    var pressure: Int = 0 // 0-100
    var usagePercent: Double {
        return total > 0 ? Double(used) / Double(total) * 100 : 0
    }
}

// MARK: - Storage Info
struct StorageInfo {
    var total: Int64 = 0
    var used: Int64 = 0
    var usagePercent: Double {
        return total > 0 ? Double(used) / Double(total) * 100 : 0
    }
}

// MARK: - Battery Info
struct BatteryInfo {
    var chargePercent: Double = 0
    var isCharging: Bool = false
    var powerWatts: Double = 0
    var cycleCount: Int = 0
    var temperature: Double = 0
    var isConnected: Bool = false
}

// MARK: - Network Info
struct NetworkInfo {
    var uploadSpeed: Double = 0 // bytes/s
    var downloadSpeed: Double = 0 // bytes/s
    var ipAddress: String = ""
    var isConnected: Bool = false
}

// MARK: - System Info Provider
class SystemInfo {
    
    // MARK: - CPU (Delta-based measurement)
    private static var previousCPUTicks: (user: UInt64, system: UInt64, idle: UInt64, nice: UInt64)?
    
    static func getCPUInfo() -> CPUInfo {
        var cpuInfo = CPUInfo()
        
        var cpuLoad = host_cpu_load_info()
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)
        
        let result = withUnsafeMutablePointer(to: &cpuLoad) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else {
            return cpuInfo
        }
        
        let currentUser = UInt64(cpuLoad.cpu_ticks.0)
        let currentSystem = UInt64(cpuLoad.cpu_ticks.1)
        let currentIdle = UInt64(cpuLoad.cpu_ticks.2)
        let currentNice = UInt64(cpuLoad.cpu_ticks.3)
        
        if let prev = previousCPUTicks {
            let deltaUser = currentUser - prev.user
            let deltaSystem = currentSystem - prev.system
            let deltaIdle = currentIdle - prev.idle
            let deltaNice = currentNice - prev.nice
            
            let totalDelta = deltaUser + deltaSystem + deltaIdle + deltaNice
            
            if totalDelta > 0 {
                cpuInfo.user = Double(deltaUser) / Double(totalDelta) * 100
                cpuInfo.system = Double(deltaSystem) / Double(totalDelta) * 100
                cpuInfo.idle = Double(deltaIdle) / Double(totalDelta) * 100
            }
        }
        
        // Store current ticks for next comparison
        previousCPUTicks = (currentUser, currentSystem, currentIdle, currentNice)
        
        return cpuInfo
    }
    
    // MARK: - Memory
    static func getMemoryInfo() -> MemoryInfo {
        var info = MemoryInfo()
        
        let hostPort = mach_host_self()
        var hostSize = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        
        var vmStat = vm_statistics64()
        let result = withUnsafeMutablePointer(to: &vmStat) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(hostSize)) {
                host_statistics64(hostPort, HOST_VM_INFO64, $0, &hostSize)
            }
        }
        
        guard result == KERN_SUCCESS else {
            return info
        }
        
        let pageSize = UInt64(vm_kernel_page_size)
        
        let active = UInt64(vmStat.active_count) * pageSize
        let wired = UInt64(vmStat.wire_count) * pageSize
        let compressed = UInt64(vmStat.compressor_page_count) * pageSize
        
        // Get total physical memory
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        
        info.total = totalMemory
        info.used = active + wired + compressed
        info.appMemory = active
        info.wiredMemory = wired
        info.compressed = compressed
        
        // Calculate memory pressure (simplified)
        let free = UInt64(vmStat.free_count) * pageSize
        let pressure = 100 - Int(Double(free) / Double(totalMemory) * 100)
        info.pressure = min(max(pressure, 0), 100)
        
        return info
    }
    
    // MARK: - Storage
    static func getStorageInfo() -> StorageInfo {
        var info = StorageInfo()
        
        let fileManager = FileManager.default
        let homeDirectory = NSHomeDirectory()
        
        do {
            let attributes = try fileManager.attributesOfFileSystem(forPath: homeDirectory)
            if let totalSize = attributes[.systemSize] as? NSNumber,
               let freeSize = attributes[.systemFreeSize] as? NSNumber {
                info.total = totalSize.int64Value
                info.used = totalSize.int64Value - freeSize.int64Value
            }
        } catch {
            print("Error getting storage info: \(error)")
        }
        
        return info
    }
    
    // MARK: - Battery
    static func getBatteryInfo() -> BatteryInfo {
        var info = BatteryInfo()
        
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue() else {
            return info
        }
        
        guard let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef] else {
            return info
        }
        
        if let psDescription = IOPSGetPowerSourceDescription(snapshot, sources.first as CFTypeRef)?.takeUnretainedValue() as? [String: Any] {
            if let capacity = psDescription[kIOPSCurrentCapacityKey] as? Int,
               let maxCapacity = psDescription[kIOPSMaxCapacityKey] as? Int {
                info.chargePercent = maxCapacity > 0 ? Double(capacity) / Double(maxCapacity) * 100 : 0
            }
            
            if let isCharging = psDescription[kIOPSIsChargingKey] as? Bool {
                info.isCharging = isCharging
            }
            
            if let isPresent = psDescription[kIOPSPowerSourceStateKey] as? String {
                info.isConnected = isPresent == "AC Power"
            }
        }
        
        // Get battery cycle count and temperature from IOKit
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleSmartBattery"))
        if service != 0 {
            var properties: Unmanaged<CFMutableDictionary>?
            if IORegistryEntryCreateCFProperties(service, &properties, kCFAllocatorDefault, 0) == KERN_SUCCESS,
               let props = properties?.takeRetainedValue() as? [String: Any] {
                
                if let cycleCount = props["CycleCount"] as? Int {
                    info.cycleCount = cycleCount
                }
                
                if let temperature = props["Temperature"] as? Int {
                    info.temperature = Double(temperature) / 100.0 // Convert from deci-Kelvin to Celsius
                }
                
                if let voltage = props["Voltage"] as? Int,
                   let current = props["Amperage"] as? Int {
                    // Power = Voltage * Current (in mW), convert to Watts
                    let powerMW = abs(Double(voltage) * Double(current)) / 1000.0
                    info.powerWatts = powerMW / 1000.0
                }
            }
            IOObjectRelease(service)
        }
        
        return info
    }
    
    // MARK: - Network
    private static var lastUploadBytes: UInt64 = 0
    private static var lastDownloadBytes: UInt64 = 0
    private static var lastNetworkTime = Date()
    
    static func getNetworkInfo() -> NetworkInfo {
        var info = NetworkInfo()
        
        // Get IP address
        info.ipAddress = getIPAddress()
        
        // Get network traffic
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            return info
        }
        
        var totalUpload: UInt64 = 0
        var totalDownload: UInt64 = 0
        var hasConnection = false
        
        var ptr = firstAddr
        while true {
            let addr = ptr.pointee
            let name = String(cString: addr.ifa_name)
            
            // Skip loopback
            if name == "lo0" {
                if let next = addr.ifa_next {
                    ptr = next
                    continue
                } else {
                    break
                }
            }
            
            if addr.ifa_addr.pointee.sa_family == UInt8(AF_LINK) {
                hasConnection = true
                if let data = addr.ifa_data?.assumingMemoryBound(to: if_data.self).pointee {
                    totalUpload += UInt64(data.ifi_obytes)
                    totalDownload += UInt64(data.ifi_ibytes)
                }
            }
            
            guard let next = addr.ifa_next else { break }
            ptr = next
        }
        
        freeifaddrs(ifaddr)
        
        let now = Date()
        let timeInterval = now.timeIntervalSince(lastNetworkTime)
        
        if timeInterval > 0 {
            if lastUploadBytes > 0 {
                info.uploadSpeed = Double(totalUpload - lastUploadBytes) / timeInterval
            }
            if lastDownloadBytes > 0 {
                info.downloadSpeed = Double(totalDownload - lastDownloadBytes) / timeInterval
            }
        }
        
        lastUploadBytes = totalUpload
        lastDownloadBytes = totalDownload
        lastNetworkTime = now
        
        info.isConnected = hasConnection
        
        return info
    }
    
    private static func getIPAddress() -> String {
        var address = ""
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            return address
        }
        
        var ptr = firstAddr
        while true {
            let addr = ptr.pointee
            let family = addr.ifa_addr.pointee.sa_family
            
            if family == UInt8(AF_INET) {
                let name = String(cString: addr.ifa_name)
                if name == "en0" || name == "en1" {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if getnameinfo(addr.ifa_addr, socklen_t(addr.ifa_addr.pointee.sa_len),
                                   &hostname, socklen_t(hostname.count),
                                   nil, 0, NI_NUMERICHOST) == 0 {
                        address = String(cString: hostname)
                    }
                }
            }
            
            guard let next = addr.ifa_next else { break }
            ptr = next
        }
        
        freeifaddrs(ifaddr)
        return address
    }
}
