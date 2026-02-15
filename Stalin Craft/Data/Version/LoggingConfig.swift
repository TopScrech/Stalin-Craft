import Foundation

struct LoggingConfig: Codable, Equatable {
    static let none = LoggingConfig(client: .none)
    
    let client: ClientLoggingConfig
}

struct ClientLoggingConfig: Codable, Equatable {
    static let none = ClientLoggingConfig(
        argument: "", 
        file: .none,
        type: ""
    )
    
    let argument: String
    let file: LoggingArtifact
    let type: String
}

struct LoggingArtifact: Codable, Equatable {
    static let none = LoggingArtifact(
        id: "", 
        sha1: "",
        size: 0,
        url: URL(string: "/")!
    )
    
    let id: String
    let sha1: String
    let size: Int
    let url: URL
}
