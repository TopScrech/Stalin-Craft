struct XboxLiveAuth: Codable {
    var RelyingParty: String
    var TokenType: String
    var Properties: XboxLiveAuthProperties
    
    struct XboxLiveAuthProperties: Codable {
        var AuthMethod: String
        var SiteName: String
        var RpsTicket: String
    }
    
    static func fromToken(_ token: String) -> XboxLiveAuth {
        .init(
            RelyingParty: "http://auth.xboxlive.com",
            TokenType: "JWT",
            Properties: .init(
                AuthMethod: "RPS",
                SiteName: "user.auth.xboxlive.com",
                RpsTicket: "d=\(token)"
            )
        )
    }
}
