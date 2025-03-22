import Foundation

extension ModList {
    func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        let fileManager = FileManager.default
        
        for provider in providers {
            // Check for file URLs directly using the loadObject method
            _ = provider.loadObject(ofClass: URL.self) { fileURL, error in
                DispatchQueue.main.async {
                    guard let fileURL, error == nil else {
                        print("Error during drop operation or failed to cast to URL: \(String(describing: error))")
                        return
                    }
                    
                    let targetURL = instance.getModsFolder().appendingPathComponent(fileURL.lastPathComponent)
                    
                    do {
                        try fileManager.moveItem(at: fileURL, to: targetURL)
                        instance.loadMods()
                        
                        logger.info("File copied successfully to \(targetURL.path)")
                    } catch {
                        logger.error("Failed to copy file", error)
                        
                        do {
                            _ = try fileManager.replaceItemAt(targetURL, withItemAt: fileURL)
                            instance.loadMods()
                            
                            logger.info("File replaced successfully")
                        } catch {
                            logger.error("Failed to replace file", error)
                        }
                    }
                }
            }
        }
        
        return true
    }
}
