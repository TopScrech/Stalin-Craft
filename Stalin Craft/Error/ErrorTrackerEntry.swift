struct ErrorTrackerEntry: Hashable {
    var type: TrackedErrorType
    var description: String
    var error: Error?
    var timestamp: Double
    var counter: Int
    
    static var counterGlobal = 0
    
    init(type: TrackedErrorType, description: String, error: Error?, timestamp: Double) {
        self.type = type
        self.description = description
        self.error = error
        self.timestamp = timestamp
        Self.counterGlobal += 1
        counter = Self.counterGlobal
    }
    
    init(type: TrackedErrorType, description: String, timestamp: Double) {
        self.init(
            type: type,
            description: description,
            error: nil,
            timestamp: timestamp
        )
    }
    
    static func == (lhs: ErrorTrackerEntry, rhs: ErrorTrackerEntry) -> Bool {
        lhs.timestamp == rhs.timestamp
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(timestamp)
    }
}
