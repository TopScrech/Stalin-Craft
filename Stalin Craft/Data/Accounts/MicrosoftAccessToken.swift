import Foundation

struct MicrosoftAccessToken: Codable {
    var token: String
    var expiry: Int
    var refreshToken: String
    
    init(token: String, expiry: Int, refreshToken: String) {
        self.token = token
        self.expiry = expiry
        self.refreshToken = refreshToken
    }
    
    init(token: String, expiresIn: Int, refreshToken: String) {
        self.token = token
        expiry = Int(CFAbsoluteTimeGetCurrent()) + expiresIn
        self.refreshToken = refreshToken
    }
    
    static func fromJson(json data: Data) throws -> MicrosoftAccessToken {
        do {
            return try JSONDecoder().decode(RawMicrosoftAccessToken.self, from: data).convert()
            
        } catch {
            throw MicrosoftAuthError.microsoftInvalidResponse
        }
    }
    
    func hasExpired() -> Bool {
        Int(CFAbsoluteTimeGetCurrent()) > expiry - 5
    }
}

struct RawMicrosoftAccessToken: Codable {
    var access_token: String
    var refresh_token: String
    var expires_in: Int
    
    func convert() -> MicrosoftAccessToken {
        MicrosoftAccessToken(
            token: access_token, 
            expiresIn: expires_in,
            refreshToken: refresh_token
        )
    }
}
