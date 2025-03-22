import SwiftUI
import FileWatcher

final class Instance: Identifiable, Hashable, InstanceData, ObservableObject {
    @Published var name: String
    
    var assetIndex: PartialAssetIndex
    var libraries: [LibraryArtifact]
    var mainClass: String
    var minecraftJar: MinecraftJar
    
    @Published var isStarred: Bool
    @Published var logo: InstanceLogo
    @Published var notes: String?
    @Published var synopsis: String?
    
    var debugString: String
    
    var synopsisOrVersion: String {
        get {
            synopsis ?? debugString
        }
        
        set(newValue) {
            synopsis = newValue
        }
    }
    
    var lastPlayed: Date?
    var preferences = InstancePreferences()
    var arguments: Arguments
    
    @Published var mods: [Mod] = []
    @Published var worlds: [World] = []
    @Published var screenshots: [Screenshot] = []
    
    var screenshotsWatcher: FileWatcher? = nil
    var modsWatcher:        FileWatcher? = nil
    var worldsWatcher:      FileWatcher? = nil
    
    init(
        name: String,
        assetIndex: PartialAssetIndex,
        libraries: [LibraryArtifact],
        mainClass: String,
        minecraftJar: MinecraftJar,
        isStarred: Bool,
        logo: InstanceLogo,
        description: String?,
        debugString: String,
        arguments: Arguments
    ) {
        self.name = name
        self.assetIndex = assetIndex
        self.libraries = libraries
        self.mainClass = mainClass
        self.minecraftJar = minecraftJar
        self.isStarred = isStarred
        self.logo = logo
        notes = description
        self.debugString = debugString
        self.arguments = arguments
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(assetIndex,   forKey: .assetIndex)
        try container.encode(libraries,    forKey: .libraries)
        try container.encode(mainClass,    forKey: .mainClass)
        try container.encode(minecraftJar, forKey: .minecraftJar)
        try container.encode(isStarred,    forKey: .isStarred)
        try container.encode(logo,         forKey: .logo)
        try container.encode(notes,        forKey: .notes)
        try container.encode(synopsis,     forKey: .synopsis)
        try container.encode(debugString,  forKey: .debugString)
        try container.encode(lastPlayed,   forKey: .lastPlayed)
        try container.encode(preferences,  forKey: .preferences)
        try container.encode(arguments,    forKey: .arguments)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = ""
        assetIndex =    try container.decode(PartialAssetIndex.self, forKey: .assetIndex)
        libraries =     try container.decode([LibraryArtifact].self, forKey: .libraries)
        mainClass =     try container.decode(String.self, forKey: .mainClass)
        minecraftJar =  try container.decode(MinecraftJar.self, forKey: .minecraftJar)
        isStarred =     try container.decode(Bool.self, forKey: .isStarred)
        logo =          try container.decode(InstanceLogo.self, forKey: .logo)
        notes =         try container.decode(String?.self, forKey: .notes)
        synopsis =      try container.decode(String?.self, forKey: .synopsis)
        debugString =   try container.decode(String.self, forKey: .debugString)
        lastPlayed =    try container.decodeIfPresent(Date.self, forKey: .lastPlayed)
        preferences =   try container.decode(InstancePreferences.self, forKey: .preferences)
        arguments =     try container.decode(Arguments.self, forKey: .arguments)
    }
    
    private enum CodingKeys: String, CodingKey {
        case name,
             assetIndex,
             libraries,
             mainClass,
             minecraftJar,
             isStarred,
             logo,
             notes,
             synopsis,
             debugString,
             synopsisOrVersion,
             lastPlayed,
             preferences,
             arguments,
             
             // Legacy
             startOnFirstThread,
             gameArguments
    }
    
    static func getInstancePath(for name: String) -> URL {
        FileHandler.instancesFolder.appendingPathComponent(name + ".pyzh", isDirectory: true)
    }
    
    func setPreferences(_ prefs: InstancePreferences) {
        preferences = prefs
    }
    
    func getPath() -> URL {
        Instance.getInstancePath(for: name)
    }
    
    func getGamePath() -> URL {
        getPath().appendingPathComponent("minecraft", isDirectory: true)
    }
    
    func getNativesFolder() -> URL {
        getPath().appendingPathComponent("natives", isDirectory: true)
    }
    
    func getMcJarPath() -> URL {
        getPath().appendingPathComponent("minecraft.jar")
    }
    
    func getLogoPath() -> URL {
        getPath().appendingPathComponent("logo.png")
    }
    
    func getModsFolder() -> URL {
        getGamePath().appendingPathComponent("mods")
    }
    
    func getScreenshotsFolder() -> URL {
        getGamePath().appendingPathComponent("screenshots")
    }
    
    func getLogsFolder() -> URL {
        getGamePath().appendingPathComponent("logs")
    }
    
    func getSavesFolder() -> URL {
        getGamePath().appendingPathComponent("saves")
    }
    
    func matchesSearchTerm(_ term: String) -> Bool {
        if term.isEmpty {
            return true
        }
        
        return name.localizedCaseInsensitiveContains(term) || synopsisOrVersion.localizedCaseInsensitiveContains(term)
    }
    
    func processArgsByRules(_ thing: KeyPath<Arguments, [ArgumentElement]>, features: [String:Bool]) -> [String] {
        arguments[keyPath: thing].filter { element in
            switch(element) {
            case .string:
                true
                
            case .object(let obj):
                obj.rules.allMatchRules(givenFeatures: features)
            }
        }
        .flatMap {
            $0.actualValue
        }
    }
    
    static func == (lhs: Instance, rhs: Instance) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(notes)
        hasher.combine(synopsisOrVersion)
    }
    
    func loadScreenshots() {
        let folder = getScreenshotsFolder()
        
        if screenshotsWatcher == nil {
            let watcher = FileWatcher([folder.path])
            watcher.queue = DispatchQueue.global(qos: .background)
            
            watcher.callback = { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.loadScreenshots()
                }
            }
            
            screenshotsWatcher = watcher
            watcher.start()
        }
        
        Task {
            let fm = FileManager.default
            var isDirectory: ObjCBool = true
            
            if fm.fileExists(atPath: folder.path, isDirectory: &isDirectory) && isDirectory.boolValue {
                let urls: [URL]
                
                do {
                    urls = try fm.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
                } catch {
                    ErrorTracker.instance.error("Error reading screenshots folder for instance \(name)", error)
                    
                    return
                }
                
                DispatchQueue.main.async {
                    self.screenshots = urls.deserializeToScreenshots().sorted()
                }
            }
        }
    }
    
    func loadMods() {
        let modsFolder = getModsFolder()
        
        if modsWatcher == nil {
            let watcher = FileWatcher([modsFolder.path])
            watcher.queue = DispatchQueue.global(qos: .background)
            
            watcher.callback = { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.loadMods()
                }
            }
            
            modsWatcher = watcher
            watcher.start()
        }
        
        Task {
            let fm = FileManager.default
            var isDirectory: ObjCBool = true
            
            if fm.fileExists(atPath: modsFolder.path, isDirectory: &isDirectory) && isDirectory.boolValue {
                let urls: [URL]
                
                do {
                    urls = try fm.contentsOfDirectory(at: modsFolder, includingPropertiesForKeys: nil)
                } catch {
                    logger.error("Error reading mods folder for instance \(name)", error)
                    
                    ErrorTracker.instance.error("Error reading mods folder for instance \(name)", error)
                    
                    return
                }
                
                DispatchQueue.main.async {
                    self.mods = urls.deserializeToMods()
                }
            }
        }
    }
    
    func loadWorlds() {
        let worldsFolder = getSavesFolder()
        
        if worldsWatcher == nil {
            let watcher = FileWatcher([worldsFolder.path])
            watcher.queue = DispatchQueue.global(qos: .background)
            
            watcher.callback = { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.loadWorlds()
                }
            }
            
            worldsWatcher = watcher
            watcher.start()
        }
        
        Task {
            let fm = FileManager.default
            var isDirectory: ObjCBool = true
            
            if fm.fileExists(atPath: worldsFolder.path, isDirectory: &isDirectory) && isDirectory.boolValue {
                let urls: [URL]
                
                do {
                    urls = try fm.contentsOfDirectory(at: worldsFolder, includingPropertiesForKeys: nil)
                    print(urls)
                } catch {
                    logger.error("Error reading mods folder for instance \(name)", error)
                    
                    ErrorTracker.instance.error("Error reading mods folder for instance \(name)", error)
                    
                    return
                }
                
                DispatchQueue.main.async {
                    self.worlds = urls.deserializeToWorlds()
                }
            }
        }
    }
}

fileprivate extension Array where Element == URL {
    func deserializeToMods() -> [Mod] {
        self.filter(Mod.isValidMod).compactMap {
            try? Mod.from(url: $0)
        }
    }
    
    func deserializeToScreenshots() -> [Screenshot] {
        self.filter {
            $0.isValidImageURL()
        }
        .map(Screenshot.init)
    }
    
    func deserializeToWorlds() -> [World] {
        self.filter {
            $0.hasDirectoryPath
        }
        .compactMap {
            .init(folder: $0.lastPathComponent)
        }
    }
}

fileprivate extension URL {
    func isValidImageURL() -> Bool {
        let validExtensions = ["jpg", "jpeg", "png", "gif"]
        
        return validExtensions.contains(self.pathExtension.lowercased())
    }
}
