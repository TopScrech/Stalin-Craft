// JSON response for both Xbox Live and XSTS Authentication

struct XboxAuthResponse: Codable {
    var issueInstant: String
    var notAfter: String
    var token: String
    var displayClaims: XboxLiveDisplayClaims
    
    struct XboxLiveDisplayClaims: Codable {
        var xui: [XboxLiveUhs]
    }
    
    struct XboxLiveUhs: Codable {
        var uhs: String
    }
    
    enum CodingKeys: String, CodingKey {
        case issueInstant = "IssueInstant",
             notAfter = "NotAfter",
             token = "Token",
             displayClaims = "DisplayClaims"
    }
    
    var userHash: String? {
        displayClaims.xui[0].uhs
    }
}
