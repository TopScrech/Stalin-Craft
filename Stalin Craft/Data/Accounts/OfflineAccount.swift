import SwiftUI

struct OfflineAccount: MinecraftAccount {
    var type: MinecraftAccountType = .offline
    var username: String
    var id: UUID
    
    var xuid: String {
        "0"
    }
    
    init(username: String, uuid: UUID) {
        self.username = username
        self.id = uuid
    }
    
    static func createFromUsername(_ username: String) -> OfflineAccount {
        .init(username: username, uuid: UUID())
    }
    
    func createAccessToken() async throws -> String {
        "offline"
    }
}
