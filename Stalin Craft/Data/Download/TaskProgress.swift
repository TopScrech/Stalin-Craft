import SwiftUI

final class TaskProgress: ObservableObject {
    @Published var current = 0
    @Published var total = 1
    
    var callback: (() -> Void)? = nil
    var cancelled = false
    
    init() {
        
    }
    
    func fraction() -> Double {
        Double(current) / Double(total)
    }
    
    func percentString() -> String {
        String(format: "%.2f", fraction() * 100) + "%"
    }
    
    @MainActor
    func inc() {
        self.current += 1
        
        if self.current == self.total {
            logger.debug("Sending download progress callback")
            callback?()
        }
        
        logger.trace("Incremented task progress to \(self.current)")
    }
    
    func intPercent() -> Int {
        Int((fraction() * 100).rounded())
    }
    
    func isDone() -> Bool {
        Int(current) >= Int(total)
    }
    
    init(current: Int, total: Int) {
        self.current = current
        self.total = total
    }
    
    static func completed() -> TaskProgress {
        .init(current: 1, total: 1)
    }
    
    func setFrom(_ other: TaskProgress) {
        current = other.current
        total = other.total
    }
}
