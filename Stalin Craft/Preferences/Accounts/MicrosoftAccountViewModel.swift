import SwiftUI

final class MicrosoftAccountVM: ObservableObject {
    @Published var message: LocalizedStringKey = "Authenticating with Microsoft"
    @Published var error: MicrosoftAuthError = .noError
    
    @Published var sheetMicrosoftAccount = false
    
    @MainActor func error(_ error: MicrosoftAuthError) {
        ErrorTracker.instance.error(NSLocalizedString("Caught error while adding Microsoft account", comment: ""), error)
        
        self.error = error
    }
    
    @MainActor func prepareAndOpenSheet(launcherData: LauncherData) {
        sheetMicrosoftAccount = true
        
        launcherData.accountManager.msAccountVM = self
        launcherData.accountManager.createAuthWindow().showWindow(StalinCraftApp.self)
    }
    
    @MainActor func closeSheet() {
        sheetMicrosoftAccount = false
        error(.noError)
        message = "Authenticating with Microsoft"
    }
    
    @MainActor func setAuthWithXboxLive() {
        message = "Authenticating with Xbox Live"
    }
    
    @MainActor func setAuthWithXboxXSTS() {
        message = "Authenticating with Xbox XSTS"
    }
    
    @MainActor func setAuthWithMinecraft() {
        message = "Authenticating with Minecraft"
    }
    
    @MainActor func setFetchingProfile() {
        message = "Fetching Profile"
    }
}
