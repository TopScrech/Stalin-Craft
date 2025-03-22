import SwiftUI

final class LauncherData: ObservableObject {
    private static var currentInstance: LauncherData? = nil
    
    static var instance: LauncherData {
        currentInstance!
    }
    
    @Published var globalPreferences = GlobalPreferences()
    @Published var javaInstallations: [SavedJavaInstallation] = []
    @Published var launchedInstances: [Instance: InstanceProcess] = [:]
    @Published var newInstanceRequested = false
    @Published var accountManager = AccountManager()
    @Published var selectedPreferenceTab: SettingsTab = .accounts
    @Published var versionManifest: [PartialVersion] = []
    
    @Published var instances:                [Instance] = []
    @Published var launchRequestedInstances: [Instance] = []
    @Published var editModeInstances:        [Instance] = []
    @Published var killRequestedInstances:   [Instance] = []
    
    private var initializedPreferenceListener = false
    
    func initializePreferenceListenerIfNot() {
        if initializedPreferenceListener {
            return
        }
        
        initializedPreferenceListener = true
        
        let preferencesWindow = NSApp.keyWindow
        
        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: preferencesWindow, queue: .main) { notification in
            DispatchQueue.global().async {
                self.globalPreferences.save()
                
                logger.debug("Saved preferences")
            }
        }
        
        logger.info("Initialized preferences save handler")
    }
    
    init() {
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                let instances = try Instance.loadInstances()
                
                DispatchQueue.main.async {
                    self.instances = instances
                }
                
                logger.info("Loaded \(instances.count) instances")
                
            } catch {
                logger.error("Could not load instances", error)
                
                ErrorTracker.instance.error("Could not load instances", error)
            }
        }
        
        Task(priority: .high) {
            do {
                let manifest = try await VersionManifest.getOrCreate()
                
                DispatchQueue.main.async {
                    self.versionManifest = manifest
                }
                
                logger.info("Loaded version manifest")
                
            } catch {
                logger.error("Could not load version manifest", error)
                logger.error("Instance creation support is limited")
                
                ErrorTracker.instance.error("Could not load version manifest", error)
            }
        }
        
        DispatchQueue.global().async {
            do {
                let globalPreferences = try GlobalPreferences.load()
                
                DispatchQueue.main.async {
                    self.globalPreferences = globalPreferences
                }
                
                logger.info("Loaded preferences")
                
            } catch {
                logger.error("Could not load preferences", error)
                logger.error("Using default values")
                
                ErrorTracker.instance.error("Could not load preferences", error)
            }
        }
        
        DispatchQueue.global().async {
            do {
                let javaInstallations = try SavedJavaInstallation.load()
                
                DispatchQueue.main.async {
                    self.javaInstallations = javaInstallations
                }
                
                logger.info("Loaded saved java runtimes")
                
            } catch {
                logger.error("Could not load saved java runtimes", error)
                logger.error("Instance launch support is limited")
                
                ErrorTracker.instance.error("Could not load saved java runtimes", error)
            }
        }
        
        DispatchQueue.global().async {
            do {
                let accountManager = try AccountManager.load()
                
                DispatchQueue.main.async {
                    self.accountManager = accountManager
                    self.accountManager.setupForAuth()
                }
                
                logger.info("Initialized account manager")
                
            } catch {
                logger.error("Could not load account manager", error)
                logger.error("Accounts support is limited")
                
                ErrorTracker.instance.error("Could not load account manager", error)
                
                self.accountManager.setupForAuth()
            }
        }
        
        LauncherData.currentInstance = self
        
        logger.debug("Initialized launcher data")
    }
}
