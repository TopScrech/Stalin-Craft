struct MinecraftAuth: Codable {
    let identityToken: String
    
    init(identityToken: String) {
        self.identityToken = identityToken
    }
    
    init(xsts xboxAuthResponse: XboxAuthResponse) {
        guard let userHash = xboxAuthResponse.userHash else {
            logger.fault("XSTS auth response did not have a user hash")
            fatalError("Invalid XSTS auth response")
        }
        
        identityToken = "XBL3.0 x=\(userHash);\(xboxAuthResponse.token)"
    }
}
