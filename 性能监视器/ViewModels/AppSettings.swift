import Foundation
import Combine

class AppSettings: ObservableObject {
    // Singleton
    static let shared = AppSettings()
    
    // General
    @Published var refreshInterval: Double
    @Published var showMenuBarPercentage: Bool
    @Published var showMenuBarIcon: Bool
    @Published var launchAtLogin: Bool
    @Published var cpuWarningThreshold: Double
    @Published var memoryWarningThreshold: Double
    @Published var warningInterval: Double // 警告间隔（分钟）
    @Published var temperatureUnit: TemperatureUnit
    
    // Monitoring toggles
    @Published var monitorMemory: Bool
    @Published var monitorStorage: Bool
    @Published var monitorBattery: Bool
    @Published var monitorNetwork: Bool
    
    // Experimental
    @Published var showSystemInfoBar: Bool
    @Published var experimentalUnlocked: Bool
    
    // Experimental - Menu Bar custom items
    @Published var showMenuBarMemory: Bool
    @Published var showMenuBarStorage: Bool
    @Published var showMenuBarBattery: Bool
    @Published var showMenuBarNetwork: Bool
    
    private var cancellables = Set<AnyCancellable>()
    
    enum TemperatureUnit: String, CaseIterable {
        case celsius = "celsius"
        case fahrenheit = "fahrenheit"
        
        var displayName: String {
            switch self {
            case .celsius: return "摄氏度 (°C)"
            case .fahrenheit: return "华氏度 (°F)"
            }
        }
    }
    
    private init() {
        // Initialize all stored properties first
        let savedRefreshInterval = UserDefaults.standard.double(forKey: "refreshInterval")
        self.refreshInterval = savedRefreshInterval == 0 ? 2.0 : savedRefreshInterval
        
        self.showMenuBarPercentage = UserDefaults.standard.object(forKey: "showMenuBarPercentage") as? Bool ?? true
        self.showMenuBarIcon = UserDefaults.standard.object(forKey: "showMenuBarIcon") as? Bool ?? true
        self.launchAtLogin = UserDefaults.standard.object(forKey: "launchAtLogin") as? Bool ?? false
        
        let savedCPUThreshold = UserDefaults.standard.double(forKey: "cpuWarningThreshold")
        self.cpuWarningThreshold = savedCPUThreshold == 0 ? 80.0 : savedCPUThreshold
        
        let savedMemoryThreshold = UserDefaults.standard.double(forKey: "memoryWarningThreshold")
        self.memoryWarningThreshold = savedMemoryThreshold == 0 ? 85.0 : savedMemoryThreshold
        
        let savedWarningInterval = UserDefaults.standard.double(forKey: "warningInterval")
        self.warningInterval = savedWarningInterval == 0 ? 5.0 : savedWarningInterval
        
        let unitRaw = UserDefaults.standard.string(forKey: "temperatureUnit") ?? TemperatureUnit.celsius.rawValue
        self.temperatureUnit = TemperatureUnit(rawValue: unitRaw) ?? .celsius
        
        // Monitoring toggles
        self.monitorMemory = UserDefaults.standard.object(forKey: "monitorMemory") as? Bool ?? true
        self.monitorStorage = UserDefaults.standard.object(forKey: "monitorStorage") as? Bool ?? true
        self.monitorBattery = UserDefaults.standard.object(forKey: "monitorBattery") as? Bool ?? true
        self.monitorNetwork = UserDefaults.standard.object(forKey: "monitorNetwork") as? Bool ?? true
        
        // Experimental
        self.showSystemInfoBar = UserDefaults.standard.object(forKey: "showSystemInfoBar") as? Bool ?? false
        self.experimentalUnlocked = UserDefaults.standard.object(forKey: "experimentalUnlocked") as? Bool ?? false
        self.showMenuBarMemory = UserDefaults.standard.object(forKey: "showMenuBarMemory") as? Bool ?? false
        self.showMenuBarStorage = UserDefaults.standard.object(forKey: "showMenuBarStorage") as? Bool ?? false
        self.showMenuBarBattery = UserDefaults.standard.object(forKey: "showMenuBarBattery") as? Bool ?? false
        self.showMenuBarNetwork = UserDefaults.standard.object(forKey: "showMenuBarNetwork") as? Bool ?? false
        
        // Now all properties are initialized, set up persistence
        setupPersistence()
    }
    
    private func setupPersistence() {
        $refreshInterval
            .dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "refreshInterval") }
            .store(in: &cancellables)
        
        $showMenuBarPercentage
            .dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "showMenuBarPercentage") }
            .store(in: &cancellables)
        
        $showMenuBarIcon
            .dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "showMenuBarIcon") }
            .store(in: &cancellables)
        
        $launchAtLogin
            .dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "launchAtLogin") }
            .store(in: &cancellables)
        
        $cpuWarningThreshold
            .dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "cpuWarningThreshold") }
            .store(in: &cancellables)
        
        $memoryWarningThreshold
            .dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "memoryWarningThreshold") }
            .store(in: &cancellables)
        
        $warningInterval
            .dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "warningInterval") }
            .store(in: &cancellables)
        
        $temperatureUnit
            .dropFirst()
            .sink { UserDefaults.standard.set($0.rawValue, forKey: "temperatureUnit") }
            .store(in: &cancellables)
        
        $monitorMemory
            .dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "monitorMemory") }
            .store(in: &cancellables)
        
        $monitorStorage
            .dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "monitorStorage") }
            .store(in: &cancellables)
        
        $monitorBattery
            .dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "monitorBattery") }
            .store(in: &cancellables)
        
        $monitorNetwork
            .dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "monitorNetwork") }
            .store(in: &cancellables)
        
        $showSystemInfoBar
            .dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "showSystemInfoBar") }
            .store(in: &cancellables)
        
        $experimentalUnlocked
            .dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "experimentalUnlocked") }
            .store(in: &cancellables)
        
        $showMenuBarMemory
            .dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "showMenuBarMemory") }
            .store(in: &cancellables)
        
        $showMenuBarStorage
            .dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "showMenuBarStorage") }
            .store(in: &cancellables)
        
        $showMenuBarBattery
            .dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "showMenuBarBattery") }
            .store(in: &cancellables)
        
        $showMenuBarNetwork
            .dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "showMenuBarNetwork") }
            .store(in: &cancellables)
    }
}
