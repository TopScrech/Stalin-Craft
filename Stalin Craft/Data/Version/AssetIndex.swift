import Foundation

final class AssetIndex: Codable {
    private static let indexesDir = FileHandler.assetsFolder.appendingPathComponent("indexes", isDirectory: true)
    private static let objectsDir = FileHandler.assetsFolder.appendingPathComponent("objects", isDirectory: true)
    let version: String
    let jsonData: Data
    let objects: [String: [String: String]]
    
    init(version: String, jsonData: Data, objects: [String: [String: String]]) {
        self.version = version
        self.jsonData = jsonData
        self.objects = objects
    }
    
    static func get(version: String, urlStr: String) throws -> AssetIndex {
        let indexesFile = AssetIndex.indexesDir.appendingPathComponent(version + ".json", isDirectory: false)
        
        if FileManager.default.fileExists(atPath: indexesFile.path) {
            return try fromJson(try Data(contentsOf: indexesFile), version: version)
        }
        
        if let url = URL(string: urlStr) {
            let contents = try Data(contentsOf: url)
            
            return try fromJson(contents, version: version)
        } else {
            fatalError("Not possible")
        }
    }
    
    static func fromJson(_ jsonData: Data, version: String) throws -> AssetIndex {
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        let objects = jsonObject["objects"] as! [String: Any]
        
        let strs = objects.mapValues {
            ($0 as! [String: Any]).mapValues { v -> String in
                if let stringValue = v as? String {
                    return stringValue
                } else if let numberValue = v as? NSNumber {
                    return numberValue.stringValue
                }
                
                print(v)
                fatalError()
            }
        }
        
        return AssetIndex(version: version, jsonData: jsonData, objects: strs)
    }
    
    func createDirectories() throws {
        let fm = FileManager.default
        let objects = FileHandler.assetsFolder.appendingPathComponent("objects", isDirectory: true)
        
        if !fm.fileExists(atPath: AssetIndex.objectsDir.path) {
            try fm.createDirectory(at: objects, withIntermediateDirectories: true)
        }
        
        if !fm.fileExists(atPath: AssetIndex.indexesDir.path) {
            try fm.createDirectory(at: AssetIndex.indexesDir, withIntermediateDirectories: true)
        }
        
        let indexFile = AssetIndex.indexesDir.appendingPathComponent(version + ".json", isDirectory: false)
        
        if !fm.fileExists(atPath: indexFile.path) {
            fm.createFile(atPath: indexFile.path, contents: jsonData)
        }
    }
    
    func getAssetsAsTasks() -> [DownloadTask] {
        var tasks: [DownloadTask] = []
        
        for (_, v) in objects {
            let hash = v["hash"]!
            let fromIndex = hash.index(hash.startIndex, offsetBy: 2)
            let hashPre = String(hash[..<fromIndex])
            let hashFolder = AssetIndex.objectsDir.appendingPathComponent(hashPre, isDirectory: true)
            let path = hashFolder.appendingPathComponent(hash, isDirectory: false)
            let url = URL(string: "https://resources.download.minecraft.net/" + hashPre + "/" + hash)!
            
            tasks.append(.init(sourceUrl: url, filePath: path, sha1: hash))
        }
        
        return tasks
    }
    
    func downloadParallel(progress: TaskProgress, onFinish: @escaping () -> Void, onError: @escaping (LaunchError) -> Void) -> URLSession? {
        do {
            try createDirectories()
        } catch {
            onError(.errorCreatingFile(error))
            
            return nil
        }
        
        let tasks = getAssetsAsTasks()
        
        return ParallelDownloader.download(tasks, progress: progress, onFinish: onFinish, onError: onError)
    }
}
