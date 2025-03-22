import ScrechKit

extension Instance {
    func save() throws {
        try FileHandler.saveData(getPath().appendingPathComponent("Instance.plist"), serialize())
    }
    
    func serialize() throws -> Data {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        
        return try encoder.encode(self)
    }
    
    internal static func deserialize(_ data: Data, path: URL) throws -> Instance {
        let decoder = PropertyListDecoder()
        
        return try decoder.decode(Instance.self, from: data)
    }
    
    static func loadFromDirectory(_ url: URL) throws -> Instance {
        guard let data = try FileHandler.getData(url.appendingPathComponent("Instance.plist")) else {
            throw NSError(domain: "", code: 228, userInfo: nil)
        }
        
        return try deserialize(data, path: url)
    }
        
    static func loadInstances() throws -> [Instance] {
        var instances: [Instance] = []
        
        let directoryContents = try FileManager.default.contentsOfDirectory(
            at: FileHandler.instancesFolder,
            includingPropertiesForKeys: nil
        )
        
        for url in directoryContents {
            if !url.hasDirectoryPath {
                continue
            }
            
            if !url.lastPathComponent.hasSuffix(".pyzh") {
                continue
            }
            
            let instance: Instance
            
            do {
                let loadedInstance = try Instance.loadFromDirectory(url)
                
                loadedInstance.name = url.deletingPathExtension().lastPathComponent
                
                instance = loadedInstance
            } catch {
                logger.error("Error loading instance at \(url.path)", error)
                
                ErrorTracker.instance.error("Error loading instance at \(url.path)", error)
                
                logger.notice("Disabling invalid instance at \(url.path)")
                
                try FileManager.default.moveItem(at: url, to: url.appendingPathExtension("_old"))
                
                continue
            }
            
            instances.append(instance)
            logger.info("Loaded instance \(instance.name)")
        }
        
        return instances
    }
    
    func createAsNewInstance() throws {
        let instancePath = getPath()
        let fm = FileManager.default
        
        if fm.fileExists(atPath: instancePath.path) {
            logger.notice("Instance already exists at path, overwriting")
            try fm.removeItem(at: instancePath)
        }
        
        try fm.createDirectory(at: instancePath, withIntermediateDirectories: true)
        
        try FileHandler.saveData(instancePath.appendingPathComponent("Instance.plist"), serialize())
        
        logger.info("Successfully created new instance \(self.name)")
    }
    
    func delete() {
        do {
            try FileManager.default.removeItem(at: getPath())
            
            logger.info("Successfully deleted instance \(self.name)")
        } catch {
            logger.error("Error deleting instance \(name)", error)
            
            ErrorTracker.instance.error("Error deleting instance \(name)", error)
        }
    }
    
    func rename(_ newName: String, completion: @escaping (Bool) -> ()) {
        let oldName = name
        let original = self.getPath()
        
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try FileManager.default.copyItem(at: original, to: Instance.getInstancePath(for: newName))
                
                do {
                    try FileManager.default.removeItem(at: original)
                    
                    logger.info("Successfully renamed instance \(oldName) to \(newName)")
                    
                    main {
                        self.name = newName
                    }
                    
                    completion(true)
                } catch {
                    logger.error("Error deleting old instance \(oldName) during rename", error)
                    
                    ErrorTracker.instance.error("Error deleting old instance \(oldName) during rename", error)
                    
                    completion(false)
                }
            } catch {
                logger.error("Error copying instance \(oldName) during rename", error)
                
                ErrorTracker.instance.error("Error copying instance \(oldName) during rename", error)
                
                completion(false)
            }
        }
    }
}
