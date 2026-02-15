import Foundation

final class DownloadedJavaInstallation: Codable {
    let version: String
    let path: String
}

extension DownloadedJavaInstallation {
    static let filePath = FileHandler.javaFolder.appendingPathComponent("Index.plist")
    static let encoder = PropertyListEncoder()
    static let decoder = PropertyListDecoder()
    
    static func load() throws -> [DownloadedJavaInstallation] {
        guard let data = try FileHandler.getData(filePath) else {
            return []
        }
        
        do {
            let versions = try decoder.decode([DownloadedJavaInstallation].self, from: data)
            logger.info("Loaded \(versions.count) downloaded java installations")
            
            return versions
        } catch {
            return []
        }
    }
}

fileprivate extension Array where Element == DownloadedJavaInstallation {
    func save() throws {
        DownloadedJavaInstallation.encoder.outputFormat = .xml
        
        let data = try DownloadedJavaInstallation.encoder.encode(self)
        try FileHandler.saveData(DownloadedJavaInstallation.filePath, data)
    }
}
