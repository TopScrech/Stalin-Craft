struct XstsAuth: Codable {
    let properties: Properties
    let relyingParty: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case properties = "Properties",
             relyingParty = "RelyingParty",
             tokenType = "TokenType"
    }
    
    struct Properties: Codable {
        let sandboxId: String
        let userTokens: [String]
        
        enum CodingKeys: String, CodingKey {
            case sandboxId = "SandboxId",
                 userTokens = "UserTokens"
        }
    }
}

extension XstsAuth {
    static func fromXblToken(_ token: String) -> Self {
        let properties = Properties(
            sandboxId: "RETAIL",
            userTokens: [token]
        )
        
        return Self(
            properties: properties,
            relyingParty: "rp://api.minecraftservices.com/",
            tokenType: "JWT"
        )
    }
}
