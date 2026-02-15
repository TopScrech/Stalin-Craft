import Foundation
import CryptoKit

struct ParallelDownloader {
    static func download(_ tasks: [DownloadTask], progress: TaskProgress, onFinish: @escaping () -> Void, onError: @escaping (LaunchError) -> Void) -> URLSession {
        logger.debug("Downloading \(tasks.count) items")
        progress.current = 0
        progress.total = tasks.count
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForResource = 180
        config.timeoutIntervalForRequest = 180
        
        let session = URLSession(configuration: config, delegate: nil, delegateQueue: nil)
        
        let downloadGroup = DispatchGroup()
        
        for (_, task) in tasks.enumerated() {
            downloadGroup.enter()
            
            let destinationUrl = task.filePath
            
            DispatchQueue.global(qos: .utility).async {
                let fileExists = FileManager.default.fileExists(atPath: destinationUrl.path)
                
                if fileExists {
                    let isHashValid = checkHash(
                        path: destinationUrl,
                        expected: task.sha1
                    )
                    
                    if isHashValid {
                        DispatchQueue.main.async {
                            progress.inc()
                            downloadGroup.leave()
                        }
                        
                        return
                    }
                }
                
                let taskUrl = task.sourceUrl
                
                let downloadTask = session.downloadTask(with: taskUrl) { tempUrl, response, error in
                    if error != nil {
                        session.invalidateAndCancel()
                        
                        DispatchQueue.main.async {
                            onError(.errorDownloading(error))
                        }
                        
                        downloadGroup.leave()
                        
                        return
                        
                    } else if let tempUrl {
                        do {
                            // Verify sha hash
                            if !checkHash(path: tempUrl, expected: task.sha1) {
                                throw LaunchError.invalidShaHash(nil)
                            }
                            
                            let fileManager = FileManager.default
                            
                            if !fileExists {
                                try fileManager.createDirectory(at: destinationUrl.deletingLastPathComponent(), withIntermediateDirectories: true)
                                
                                if !FileManager.default.fileExists(atPath: destinationUrl.path) {
                                    try fileManager.moveItem(at: tempUrl, to: destinationUrl)
                                }
                            }
                            
                            DispatchQueue.main.async {
                                progress.inc()
                            }
                            
                        } catch {
                            session.invalidateAndCancel()
                            
                            if let error = error as? LaunchError {
                                DispatchQueue.main.async {
                                    onError(error)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    onError(.unknown(error))
                                }
                            }
                        }
                    }
                    
                    downloadGroup.leave()
                }
                
                downloadTask.resume()
            }
        }
        
        downloadGroup.notify(queue: .main) {
            DispatchQueue.main.async {
                logger.debug("Successfully downloaded \(tasks.count) items")
                onFinish()
            }
        }
        
        return session
    }
    
    private static func calculateSHA1Hash(for filePath: URL) -> String? {
        do {
            let fileData = try Data(contentsOf: filePath)
            let digest = Insecure.SHA1.hash(data: fileData)
            
            return digest.map {
                String(format: "%02hhx", $0)
            }
            .joined()
            
        } catch {
            logger.error("Failed to read file", error)
            
            return nil
        }
    }
    
    private static func checkHash(path: URL, expected expectedHashString: String?) -> Bool {
        if let expectedHashString {
            if let actualHashString = calculateSHA1Hash(for: path) {
                actualHashString == expectedHashString
            } else {
                false
            }
        } else {
            true
        }
    }
}
