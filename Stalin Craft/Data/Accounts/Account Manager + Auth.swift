import Foundation

extension AccountManager {
    func setupMicrosoftAccount(code: String) {
        guard let msAccountVM else {
            return
        }
        
        Task(priority: .high) {
            do {
                let msAccessToken: MicrosoftAccessToken = try await authenticateWithMicrosoft(code: code, clientId: clientId)
                
                DispatchQueue.main.async {
                    msAccountVM.setAuthWithXboxLive()
                }
                
                logger.debug("Authenticated with microsoft")
                let xblResponse = try await authenticateWithXBL(msAccessToken: msAccessToken.token)
                
                DispatchQueue.main.async {
                    msAccountVM.setAuthWithXboxXSTS()
                }
                
                logger.debug("Authenticated with xbox live")
                let xstsResponse: XboxAuthResponse = try await authenticateWithXSTS(xblToken: xblResponse.token)
                
                DispatchQueue.main.async {
                    msAccountVM.setAuthWithMinecraft()
                }
                
                logger.debug("Authenticated with xbox xsts")
                let mcResponse: MinecraftAuthResponse = try await authenticateWithMinecraft(using: .init(xsts: xstsResponse))
                
                DispatchQueue.main.async {
                    msAccountVM.setFetchingProfile()
                }
                
                logger.debug("Authenticated with minecraft")
                let profile: MinecraftProfile = try await getProfile(accessToken: mcResponse.accessToken)
                logger.debug("Fetched minecraft profile")
                
                let account = MicrosoftAccount(profile: profile, token: msAccessToken)
                accounts[account.id] = account
                logger.info("Successfully added microsoft account \(profile.name)")
                
                DispatchQueue.main.async {
                    msAccountVM.closeSheet()
                    self.msAccountVM = nil
                }
                
            } catch let error as MicrosoftAuthError {
                logger.error("Caught error during authentication", error)
                
                DispatchQueue.main.async {
                    msAccountVM.error(error)
                    self.msAccountVM = nil
                }
                
                return
                
            } catch {
                fatalError("Unknown error - this is bug - \(error)")
            }
        }
    }
    
    func authenticateWithMinecraft(using auth: MinecraftAuth) async throws -> MinecraftAuthResponse {
        do {
            let (data, response) = try await Http.post("https://api.minecraftservices.com/authentication/login_with_xbox")
                .json(auth)
                .request()
            
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                logger.error("Received invalid status code from minecraft authentication server")
                throw MicrosoftAuthError.minecraftInvalidResponse
            }
            
            do {
                let result = try JSONDecoder().decode(MinecraftAuthResponse.self, from: data)
                
                return result
                
            } catch {
                logger.error("Received malformed response from minecraft authentication server", error)
                
                throw MicrosoftAuthError.minecraftInvalidResponse
            }
            
        } catch let err as MicrosoftAuthError {
            throw err
            
        } catch {
            throw MicrosoftAuthError.minecraftCouldNotConnect
        }
    }
    
    func authenticateWithXBL(msAccessToken: String) async throws -> XboxAuthResponse {
        let xboxLiveParameters = XboxLiveAuth.fromToken(msAccessToken)
        
        do {
            let (data, response) = try await Http.post("https://user.auth.xboxlive.com/user/authenticate")
                .json(xboxLiveParameters)
                .header("application/json", field: "Accept")
                .request()
            
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                logger.error("Received invalid status code from xbox live authentication server")
                throw MicrosoftAuthError.xboxInvalidResponse
            }
            
            do {
                return try JSONDecoder().decode(XboxAuthResponse.self, from: data)
                
            } catch {
                logger.error("Received malformed response from xbox live authentication server", error)
                
                throw MicrosoftAuthError.xboxInvalidResponse
            }
            
        } catch let err as MicrosoftAuthError {
            throw err
            
        } catch {
            throw MicrosoftAuthError.xboxCouldNotConnect
        }
    }
    
    func authenticateWithXSTS(xblToken: String) async throws -> XboxAuthResponse {
        let xstsAuthParameters = XstsAuth.fromXblToken(xblToken)
        
        do {
            let (data, response) = try await Http.post("https://xsts.auth.xboxlive.com/xsts/authorize")
                .json(xstsAuthParameters)
                .header("application/json", field: "Accept")
                .request()
            
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                logger.error("Received invalid status code from xbox xsts authentication server")
                throw MicrosoftAuthError.xstsInvalidResponse
            }
            
            do {
                return try JSONDecoder().decode(XboxAuthResponse.self, from: data)
                
            } catch {
                logger.error("Received malformed response from xbox xsts authentication server", error)
                
                throw MicrosoftAuthError.xstsInvalidResponse
            }
            
        } catch let err as MicrosoftAuthError {
            throw err
            
        } catch {
            throw MicrosoftAuthError.xstsCouldNotConnect
        }
    }
    
    func authenticateWithMicrosoft(code: String, clientId: String) async throws -> MicrosoftAccessToken {
        let msParameters = [
            "client_id": clientId,
            "scope": "XboxLive.signin offline_access",
            "code": code,
            "redirect_uri": "http://localhost:1989",
            "grant_type": "authorization_code"
        ]
        
        do {
            let (data, response) = try await Http.post("https://login.microsoftonline.com/consumers/oauth2/v2.0/token")
                .body(msParameters.percentEncoded())
                .header("application/x-www-form-urlencoded", field: "Content-Type")
                .request()
            
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                logger.error("Received invalid status code from microsoft authentication server")
                
                throw MicrosoftAuthError.microsoftInvalidResponse
            }
            
            do {
                return try MicrosoftAccessToken.fromJson(json: data)
                
            } catch {
                logger.error("Received malformed response from microsoft authentication server", error)
                
                throw MicrosoftAuthError.microsoftInvalidResponse
            }
            
        } catch let err as MicrosoftAuthError {
            throw err
            
        } catch {
            throw MicrosoftAuthError.microsoftCouldNotConnect
        }
    }
    
    func refreshMicrosoftToken(_ token: MicrosoftAccessToken) async throws -> MicrosoftAccessToken {
        let msParameters = [
            "client_id":     clientId,
            "scope":         "XboxLive.signin offline_access",
            "refresh_token": token.refreshToken,
            "grant_type":    "refresh_token"
        ]
        
        do {
            let (data, response) = try await Http.post("https://login.microsoftonline.com/consumers/oauth2/v2.0/token")
                .body(msParameters.percentEncoded())
                .header("application/x-www-form-urlencoded", field: "Content-Type")
                .request()
            
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                logger.error("Received invalid status code from microsoft refresh server")
                
                throw MicrosoftAuthError.microsoftInvalidResponse
            }
            
            do {
                return try MicrosoftAccessToken.fromJson(json: data)
                
            } catch {
                logger.error("Received malformed response from microsoft refresh server", error)
                
                throw MicrosoftAuthError.microsoftInvalidResponse
            }
            
        } catch let err as MicrosoftAuthError {
            throw err
            
        } catch {
            throw MicrosoftAuthError.microsoftCouldNotConnect
        }
    }
    
    func getProfile(accessToken: String) async throws -> MinecraftProfile {
        do {
            let (data, response) = try await Http.get("https://api.minecraftservices.com/minecraft/profile")
                .header("Bearer \(accessToken)", field: "Authorization")
                .request()
            
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                logger.error("Received invalid status code from minecraft profile server")
                
                throw MicrosoftAuthError.profileInvalidResponse
            }
            
            do {
                return try JSONDecoder().decode(MinecraftProfile.self, from: data)
                
            } catch {
                logger.error("Received malformed response from minecraft profile server", error)
                
                throw MicrosoftAuthError.profileInvalidResponse
            }
            
        } catch let err as MicrosoftAuthError {
            throw err
            
        } catch {
            throw MicrosoftAuthError.profileCouldNotConnect
        }
    }
}
