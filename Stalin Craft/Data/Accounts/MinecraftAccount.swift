import SwiftUI

protocol MinecraftAccount: Codable, Hashable {
    var id: UUID { get }
    
    var type: MinecraftAccountType { get }
    
    var username: String { get }
    
    var xuid: String { get }
    
    static func createFromDict(_ dict: [String: Any]) -> Self
    
    func createAccessToken() async throws -> String
}

fileprivate let decoder = PropertyListDecoder()

extension MinecraftAccount {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.username == rhs.username
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(username)
    }
    
    static func createFromDict(_ dict: [String: Any]) -> Self {
        let data = try! PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0)
        
        let decoded = try! decoder.decode(Self.self, from: data)
        
        return decoded
    }
}
