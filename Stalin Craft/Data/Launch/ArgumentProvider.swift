import Foundation

final class ArgumentProvider {
    var values: [String: String] = [:]
    
    init() {
        
    }
    
    func accept(_ str: [String]) -> [String] {
        str.map {
            replaceVariables(in: $0)
        }
    }
    
    private func replaceVariables(in str: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: #"\$\{([^}]+)\}"#) else {
            return str
        }
        
        let nsRange = NSRange(str.startIndex..<str.endIndex, in: str)
        let matches = regex.matches(in: str, range: nsRange)
        
        if matches.isEmpty {
            return str
        }
        
        var replaced = str
        
        for match in matches.reversed() {
            guard let placeholderRange = Range(match.range(at: 0), in: replaced),
                  let variableRange = Range(match.range(at: 1), in: str) else {
                continue
            }
            
            let variable = String(str[variableRange])
            
            guard let value = values[variable] else {
                continue
            }
            
            replaced.replaceSubrange(placeholderRange, with: value)
        }
        
        return replaced
    }
    
    func clientId(_ clientId: String) {
        values["clientId"] = clientId
        values["clientid"] = clientId
    }
    
    func launcher(name: String, version: String) {
        values["launcher_name"] = name
        values["launcher_version"] = version
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
    
    func classpath(_ classpath: String) {
        values["classpath"] = classpath
        values["classpath_separator"] = ":"
        values["library_directory"] = FileHandler.librariesFolder.path
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
