import Foundation
import CryptoKit

final class ParallelExecutor {
    static func run(_ tasks: [() -> Void], progress: TaskProgress) {
        progress.current = 0
        progress.total = tasks.count
        
        logger.debug("Executing \(tasks.count) tasks")
        
        for task in tasks {
            Task(priority: .medium) {
                task()
                
                DispatchQueue.main.async {
                    progress.inc()
                }
            }
        }
    }
    
    internal static func isSha1Valid(data: Data, expected: String?) -> Bool {
        guard let expected else {
            return true
        }
        
        let real = Insecure.SHA1.hash(data: data).compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return real == expected
    }
}
