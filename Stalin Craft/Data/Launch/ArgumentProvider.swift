import Foundation

final class ArgumentProvider {
    var values: [String:String] = [:]
    
    init() {
        
    }
    
    func accept(_ str: [String]) -> [String] {
        var visited: [String] = []
        
        for component in str {
            if component[component.startIndex] != "$" {
                visited.append(component)
                continue
            }
            
            let variable = String(component.dropFirst(2).dropLast())
            
            if let value = values[variable] {
                visited.append(value)
            }
        }
        
        return visited
    }
    
    func clientId(_ clientId: String) {
        values["clientId"] = clientId
    }
    
    func xuid(_ xuid: String) {
        values["auth_xuid"] = xuid
    }
    
    func username(_ username: String) {
        values["auth_player_name"] = username
    }
    
    func version(_ version: String) {
        values["version_name"] = version
        values["version"] = version
    }
    
    func gameDir(_ gameDir: URL) {
        values["game_directory"] = gameDir.path
    }
    
    func assetsDir(_ assetsDir: URL) {
        values["assets_root"] = assetsDir.path
        values["game_assets"] = assetsDir.path
    }
    
    func assetIndex(_ assetIndex: String) {
        values["assets_index_name"] = assetIndex
    }
    
    func nativesDir(_ directory: String) {
        values["natives_directory"] = directory
    }
    
    func uuid(_ uuid: UUID) {
        values["auth_uuid"] = uuid.uuidString
        values["uuid"] = uuid.uuidString
    }
    
    func accessToken(_ accessToken: String) {
        values["auth_access_token"] = accessToken
        values["auth_session"] = accessToken
        values["accessToken"] = accessToken
    }
    
    func userType(_ userType: String) {
        values["user_type"] = userType
    }
    
    func versionType(_ versionType: String) {
        values["version_type"] = versionType
    }
    
    func width(_ width: Int) {
        values["resolution_width"] = String(width)
    }
    
    func height(_ height: Int) {
        values["resolution_height"] = String(height)
    }
}
