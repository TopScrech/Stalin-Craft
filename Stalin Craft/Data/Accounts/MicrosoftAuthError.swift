enum MicrosoftAuthError: Error {
    case noError,
         microsoftCouldNotConnect,
         microsoftInvalidResponse,
         xboxCouldNotConnect,
         xboxInvalidResponse,
         xstsCouldNotConnect,
         xstsInvalidResponse,
         minecraftCouldNotConnect,
         minecraftInvalidResponse,
         profileCouldNotConnect,
         profileInvalidResponse
    
    var localizedDescription: String {
        switch (self) {
        case .noError:
            "No error!"
            
        case .microsoftCouldNotConnect:
            "Could not connect to Microsoft authentication server"
            
        case .microsoftInvalidResponse:
            "Invalid response received from Microsoft authentication server"
            
        case .xboxCouldNotConnect:
            "Could not connect to Xbox Live authentication server"
            
        case .xboxInvalidResponse:
            "Invalid response received from Xbox Live authentication server"
            
        case .xstsCouldNotConnect:
            "Could not connect to Xbox XSTS authentication server"
            
        case .xstsInvalidResponse:
            "Invalid response received from Xbox XSTS authentication server"
            
        case .minecraftCouldNotConnect:
            "Could not connect to Minecraft authentication server"
            
        case .minecraftInvalidResponse:
            "Invalid response received from Minecraft authentication server"
            
        case .profileCouldNotConnect:
            "Could not connect to Minecraft profile server"
            
        case .profileInvalidResponse:
            "Invalid response received from Minecraft profile server"
        }
    }
}
