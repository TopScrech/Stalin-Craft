import SwiftUI

struct DeveloperModeCommands: Commands {
    @AppStorage("devMode") var devMode = true
    
    var body: some Commands {
        getCommands()
    }
    
    @ViewBuilder
    func createView() -> some View {
        Button("Open console") {
            Task {
                let workspace = NSWorkspace.shared
                let consoleURL = URL(fileURLWithPath: "/System/Applications/Utilities/Console.app")
                let appURL = Bundle.main.bundleURL
                let config = NSWorkspace.OpenConfiguration()
                
                config.arguments = [appURL.path]
                
                try await workspace.openApplication(at: consoleURL, configuration: config)
            }
        }
        
        Button("Error Tracker") {
            ErrorTracker.instance.showWindow()
        }
    }
    
    @CommandsBuilder
    func getCommands() -> some Commands {
        CommandMenu("Develop") {
            if devMode {
                createView()
            }
        }
    }
}
