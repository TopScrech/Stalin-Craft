struct MinecraftAuthResponse: Codable {
    let username: String
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case username,
             accessToken = "access_token",
             tokenType = "token_type",
             expiresIn = "expires_in"
    }
}
