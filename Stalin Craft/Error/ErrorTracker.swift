import Cocoa

final class ErrorTracker: ObservableObject {
    static var instance = ErrorTracker()
    
    @Published var errors: [ErrorTrackerEntry] = []
    
    private var windowControllerTemp: ErrorTrackerWindowController? = nil
    
    private var windowController: ErrorTrackerWindowController {
        if let windowControllerTemp {
            return windowControllerTemp
        }
        
        windowControllerTemp = .init()
        
        return windowControllerTemp!
    }
    
    func error(_ description: String, _ error: Error? = nil) {
        if let error {
            logger.error(description, error)
        } else {
            logger.error("\(description)")
        }
        
        errors.append(.init(
            type: .error,
            description: description,
            error: error,
            timestamp: CFAbsoluteTime()
        ))
    }
    
    func nonEssentialError(description: String) {
        errors.append(.init(
            type: .nonEssentialError, 
            description: description,
            timestamp: CFAbsoluteTime()
        ))
    }
    
    func showWindow() {
        windowController.showWindow(StalinCraftApp.self)
    }
}
