import Foundation

enum LaunchError: Error {
    case errorDownloading  (_ error: Error?),
         invalidShaHash    (_ error: Error?),
         unknown           (_ error: Error?),
         accessTokenFetch  (_ error: Error?),
         errorCreatingFile (_ error: Error?)
    
    var cause: Error? {
        switch(self) {
        case .errorDownloading(let error),
                .invalidShaHash(let error),
                .unknown(let error),
                .accessTokenFetch(let error),
                .errorCreatingFile(let error):
            
            return error
        }
    }
    
    var localizedDescription: String {
        switch(self) {
        case .errorDownloading(_):
            NSLocalizedString("Failed to download specified file", comment: "no u")
            
        case .invalidShaHash(_):
            NSLocalizedString("Invalid SHA hash found", comment: "no u")
            
        case .unknown(_):
            NSLocalizedString("An unknown error occurred while downloading. This is a bug!", comment: "no u")
            
        case .accessTokenFetch(_):
            NSLocalizedString("Couldn't fetch Minecraft access token", comment: "no u")
            
        case .errorCreatingFile(_):
            NSLocalizedString("Failed to create file/directory", comment: "no u")
        }
    }
}
