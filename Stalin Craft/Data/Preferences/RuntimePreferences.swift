import Foundation

final class RuntimePreferences: Codable, ObservableObject {
    @Published var defaultJava: SavedJavaInstallation = .systemDefault
    @Published var minMemory = 1024
    @Published var maxMemory = 1024
    @Published var javaArgs = ""
    @Published var valid = true
    
    init() {
        
    }
    
    init(_ prefs: RuntimePreferences) {
        defaultJava = prefs.defaultJava
        minMemory =   prefs.minMemory
        maxMemory =   prefs.maxMemory
        javaArgs =    prefs.javaArgs
        valid =       prefs.valid
    }
    
    func invalidate() -> RuntimePreferences {
        valid = false
        
        return self
    }
    
    static func invalid() -> RuntimePreferences {
        .init().invalidate()
    }
}
