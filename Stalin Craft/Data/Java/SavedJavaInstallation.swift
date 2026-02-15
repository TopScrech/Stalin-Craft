import Foundation

final class SavedJavaInstallation: Codable, Identifiable, ObservableObject {
    static let systemDefault = SavedJavaInstallation(
        javaHomePath: "/usr",
        javaVendor: "System Default",
        javaVersion: ""
    )
    
    private static let regex = try! NSRegularExpression(pattern: "\"([^\"]+)\"", options: [])
    
    var id: SavedJavaInstallation {
        self
    }
    
    @Published var javaExecutable: String
    @Published var javaVendor: String?
    @Published var javaVersion: String?
    
    let installationType: InstallationType
    
    init(javaHomePath: String, javaVendor: String? = nil, javaVersion: String? = nil) {
        javaExecutable = "\(javaHomePath)/bin/java"
        self.javaVendor = javaVendor
        self.javaVersion = javaVersion
        installationType = .detected
    }
    
    init(javaExecutable: String) {
        self.javaExecutable = javaExecutable
        javaVendor = nil
        javaVersion = nil
        installationType = .selected
    }
    
    init(linkedJavaInstallation: LinkedJavaInstallation) {
        javaExecutable = "\(linkedJavaInstallation.JVMHomePath)/bin/java"
        javaVendor = linkedJavaInstallation.JVMVendor
        javaVersion = linkedJavaInstallation.JVMVersion
        installationType = .detected
    }
    
    func setupAsNewVersion(launcherData: LauncherData) {
        DispatchQueue.global(qos: .utility).async {
            let process = Process()
            
            let pipe = Pipe()
            process.executableURL = URL(fileURLWithPath: self.javaExecutable)
            process.arguments = ["-XshowSettings:properties", "-version"]
            process.standardOutput = pipe
            process.standardError = pipe
            process.launch()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.availableData
            let string = String(data: data, encoding: .utf8) ?? "NO U"
            
            if let vendor = self.extractProperty(from: string, key: "java.vendor"),
               let version = self.extractProperty(from: string, key: "java.version") {
                self.javaVendor = vendor
                self.javaVersion = version
            } else {
                logger.warning("Unable to extract properties from selected java runtime")
                logger.warning("Use Java 7 or above to suppress this warning")
            }
            
            DispatchQueue.main.async {
                launcherData.javaInstallations.append(self)
            }
            
            do {
                try launcherData.javaInstallations.save()
            } catch {
                logger.error("Could not save java runtime index", error)
                ErrorTracker.instance.error("Could not save java runtime index", error)
            }
        }
    }
    
    private func extractProperty(from output: String, key: String) -> String? {
        let lines = output.components(separatedBy: .newlines)
        
        for line in lines {
            if line.contains(key) {
                let components = line.components(separatedBy: "=")
                
                if components.count == 2 {
                    return components[1].trimmingCharacters(in: .whitespaces)
                }
            }
        }
        
        return nil
    }
    
    func getString() -> String {
        guard let javaVersion else {
            guard let javaVendor else {
                return javaExecutable
            }
            
            return "\(javaVendor) at \(javaExecutable)"
        }
        
        guard let javaVendor else {
            return "\(javaVersion) | \(javaExecutable)"
        }
        
        return "\(javaVersion) | \(javaVendor) at \(javaExecutable)"
    }
    
#warning("Computed property? Allows using a keypath in Table")
    func getDebugString() -> String {
        if let javaVersion {
            if let javaVendor {
                "\(javaVendor) \(javaVersion)"
            } else {
                javaVersion
            }
        } else {
            if let javaVendor {
                javaVendor
            } else {
                "Unknown"
            }
        }
    }
    
    enum InstallationType: Codable, Hashable {
        case detected, // detected from /usr/libexec/java_home
             selected, // user selected
             downloaded // downloaded by Stalin Craft
    }
}

extension SavedJavaInstallation {
    static let filePath = FileHandler.javaFolder.appendingPathComponent("Saved.plist")
    static let encoder = PropertyListEncoder()
    static let decoder = PropertyListDecoder()
    
    static func load() throws -> [SavedJavaInstallation] {
        let data = try? FileHandler.getData(filePath)
        
        guard let data else {
            let saved = try LinkedJavaInstallation.getAll().toSaved()
            try saved.save()
            
            return saved
        }
        
        do {
            let versions = try decoder.decode([SavedJavaInstallation].self, from: data)
            return versions
        } catch {
            try FileManager.default.removeItem(at: filePath)
            return []
        }
    }
}

extension SavedJavaInstallation: Hashable {
    static func == (lhs: SavedJavaInstallation, rhs: SavedJavaInstallation) -> Bool {
        lhs.javaExecutable == rhs.javaExecutable
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(javaExecutable)
    }
}

fileprivate extension Array where Element == SavedJavaInstallation {
    func save() throws {
        SavedJavaInstallation.encoder.outputFormat = .xml
        
        let data = try SavedJavaInstallation.encoder.encode(self)
        
        try FileHandler.saveData(SavedJavaInstallation.filePath, data)
    }
}

fileprivate extension Array where Element == LinkedJavaInstallation {
    func toSaved() -> [SavedJavaInstallation] {
        self.map {
            .init(linkedJavaInstallation: $0)
        }
    }
}
