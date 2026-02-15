@propertyWrapper
struct RunOnce {
    private var hasRun = false
    private let action: () -> Void
    
    init(wrappedValue: @escaping () -> Void) {
        action = wrappedValue
    }
    
    var wrappedValue: () -> Void {
        mutating get {
            if !hasRun {
                hasRun = true
                
                return action
            } else {
                return {}
            }
        }
    }
}
