import Foundation

final class GlobalPreferences: Codable, ObservableObject {
    @Published var runtime = RuntimePreferences()
    @Published var ui = UiPreferences()
    
    static let filePath = try! FileHandler.getOrCreateFolder().appendingPathComponent("Preferences.plist")
    
    static func load() throws -> GlobalPreferences {
        if let data = try FileHandler.getData(filePath) {
            return try PropertyListDecoder().decode(GlobalPreferences.self, from: data)
            
        } else {
            let prefs = GlobalPreferences()
            prefs.save()
            
            return prefs
        }
    }
    
    func save() {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        
        do {
            let data = try encoder.encode(self)
            try FileHandler.saveData(GlobalPreferences.filePath, data)
            
        } catch {
            logger.error("Could not serialize preferences")
            
            ErrorTracker.instance.error("Could not serialize preferences", error)
        }
    }
}
