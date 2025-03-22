import Foundation

final class VersionManifest {
    private static let cache = try! FileHandler.getOrCreateFolder().appendingPathComponent("ManifestCache.plist")
    private static var cached: [PartialVersion]? = nil
    private static let decoder = JSONDecoder()
    
    static func getOrCreate() async throws -> [PartialVersion] {
        guard let cached else {
            return try await download()
        }
        
        return cached
    }
    
    static func download() async throws -> [PartialVersion] {
        let urlString = "https://piston-meta.mojang.com/mc/game/version_manifest_v2.json"
        
        guard let url = URL(string: urlString) else {
            fatalError("Not possible")
        }
        
        let data: Data
        
        do {
            data = try await URLSession.shared.data(from: url).0
        } catch {
            logger.error("Could not download version manifest", error)
            
            ErrorTracker.instance.error("Could not download version manifest", error)
            
            logger.error("Trying to load cached version manifest")
            
            return try fetchCache()
        }
        
        let parsed = try readFromData(data)
        
        Task {
            try FileHandler.saveData(cache, PropertyListEncoder().encode(parsed))
        }
        
        return parsed
    }
    
    static func fetchCache() throws -> [PartialVersion] {
        guard let data = try FileHandler.getData(cache) else {
            logger.error("Did not find cached version manifest")
            
            throw VersionManifestError.noCacheFound
        }
        
        return try PropertyListDecoder().decode([PartialVersion].self, from: data)
    }
    
    static func readFromData(_ data: Data) throws -> [PartialVersion] {
        try decoder.decode(RootJSON.self, from: data).versions
    }
    
    enum VersionManifestError: Error {
        case noCacheFound
        
        var localizedDescription: String {
            switch(self) {
            case .noCacheFound:
                "Missing version manifest cache and could not download from version manifest"
            }
        }
    }
}

struct RootJSON: Codable {
    let versions: [PartialVersion]
}
