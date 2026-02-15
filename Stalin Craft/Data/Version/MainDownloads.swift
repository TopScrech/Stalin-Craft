import Foundation

struct MainDownloads: Codable, Equatable {
    static let none = MainDownloads(
        client: .none,
        clientMappings: nil,
        server: nil,
        serverMappings: nil,
        windowsServer: nil
    )
    
    let client: Artifact
    let clientMappings: Artifact?
    let server: Artifact?
    let serverMappings: Artifact?
    let windowsServer: Artifact?
    
    enum CodingKeys: String, CodingKey {
        case client,
             clientMappings = "client_mappings",
             server,
             serverMappings = "server_mappings",
             windowsServer = "windows_server"
    }
    
    static func |(lhs: MainDownloads, rhs: MainDownloads) -> MainDownloads {
        let mergedClient =         lhs.client != .none ? lhs.client : rhs.client
        let mergedClientMappings = lhs.clientMappings != nil ? lhs.clientMappings : rhs.clientMappings
        let mergedServer =         lhs.server != nil ? lhs.server : rhs.server
        let mergedServerMappings = lhs.serverMappings != nil ? lhs.serverMappings : rhs.serverMappings
        let mergedWindowsServer =  lhs.windowsServer != nil ? lhs.windowsServer : rhs.windowsServer
        
        return .init(
            client: mergedClient,
            clientMappings: mergedClientMappings,
            server: mergedServer,
            serverMappings: mergedServerMappings,
            windowsServer: mergedWindowsServer
        )
    }
}
