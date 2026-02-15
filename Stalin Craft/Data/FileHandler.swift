import Foundation

final class FileHandler {
    static let instancesFolder = try! getOrCreateFolder("Instances")
    static let assetsFolder = try! getOrCreateFolder("Assets")
    static let librariesFolder = try! getOrCreateFolder("Libraries")
    static let javaFolder = try! getOrCreateFolder("Java")
    
    static func getOrCreateFolder() throws -> URL {
        let fileManager = FileManager.default
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folderUrl = appSupport.appendingPathComponent("Stalin Craft")
        
        if !fileManager.fileExists(atPath: folderUrl.path) {
            logger.info("Creating directory in user's application support folder")
            try fileManager.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
        }
        
        return folderUrl
    }
    
    static func getOrCreateFolder(_ name: String) throws -> URL {
        let fileManager = FileManager.default
        let folderUrl = try getOrCreateFolder().appendingPathComponent(name)
        
        if !fileManager.fileExists(atPath: folderUrl.path) {
            logger.info("Creating subdirectory \(name) in Stalin Craft")
            try fileManager.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
        }
        
        return folderUrl
    }
    
    static func getData(_ url: URL) throws -> Data? {
        if !FileManager.default.fileExists(atPath: url.path) {
            return nil
        }
        
        return try Data(contentsOf: url)
    }
    
    static func saveData(_ url: URL, _ data: Data) throws {
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: data)
        } else {
            try data.write(to: url)
        }
    }
}
