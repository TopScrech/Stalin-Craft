import SwiftUI

struct InstanceView: View {
    @StateObject private var editingVM = InstanceEditingVM()
    @StateObject var instance: Instance
    @EnvironmentObject private var launcherData: LauncherData
    
    init(_ instance: Instance) {
        _instance = StateObject(wrappedValue: instance)
    }
    
    @State private var disabled = false
    @State private var starHovered = false
    @State private var logoHovered = false
    @State private var launchError: LaunchError? = nil
    
    @State private var downloadSession: URLSession? = nil
    @State private var downloadMessage: LocalizedStringKey = "Downloading Libraries"
    @State private var downloadProgress = TaskProgress(current: 0, total: 1)
    
    @State private var progress: Float = 0
    @State private var launchedInstanceProcess: InstanceProcess? = nil
    @State private var indeterminateProgress = false
    
    @State private var popoverNoName = false
    @State private var popoverDuplicate = false
    @State private var sheetError = false
    @State private var sheetPrelaunch = false
    @State private var sheetChooseAccount = false
    @State private var sheetLogo = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    InstanceInterativeLogoView(
                        instance: instance,
                        sheetLogo: $sheetLogo,
                        logoHovered: $logoHovered
                    )
                    
                    VStack {
                        HStack {
                            InstanceTitleView(
                                editingVM: editingVM,
                                instance: instance,
                                popoverNoName: $popoverNoName,
                                popoverDuplicate: $popoverDuplicate,
                                starHovered: $starHovered
                            )
                            
                            Spacer()
                        }
                        
                        HStack {
                            InstanceSynopsisView(editingVM: editingVM, instance: instance)
                            
                            Spacer()
                        }
                        .padding(.top, 10)
                    }
                }
                .sheet($sheetLogo) {
                    InstanceLogoSheet(instance: instance)
                }
                
                HStack {
                    InstanceNotesView(editingVM: editingVM, instance: instance)
                    
                    Spacer()
                }
                
                Spacer()
                
                TabView {
                    InstanceConsoleView(
                        instance: instance,
                        launchedInstanceProcess: $launchedInstanceProcess
                    )
                    .tabItem {
                        Label("Console", systemImage: "bolt")
                    }
                    
                    ModList(instance: instance)
                        .tabItem {
                            Label("Mods", systemImage: "plus.square.on.square")
                        }
                    
                    ScreenshotList(instance: instance)
                        .tabItem {
                            Label("Screenshots", systemImage: "plus.square.on.square")
                        }
                    
                    WorldList(instance: instance)
                        .tabItem {
                            Label("Worlds", systemImage: "plus.square.on.square")
                        }
                    
                    ServerList()
                        .environmentObject(instance)
                        .tabItem {
                            Label("Servers", systemImage: "server.rack")
                        }
                    
                    InstanceRuntimeView(instance: instance)
                        .tabItem {
                            Label("Settings", systemImage: "bolt")
                        }
                }
                .padding(4)
            }
            .padding(6)
            .task {
                launcherData.launchRequestedInstances.removeAll {
                    $0 == instance
                }
                
                launchedInstanceProcess = launcherData.launchedInstances[instance]
                instance.loadScreenshots()
            }
            .sheet($sheetError) {
                LaunchErrorSheet(launchError: $launchError)
            }
            .sheet($sheetPrelaunch, content: createPrelaunchSheet)
            .sheet($sheetChooseAccount) {
                InstanceChooseAccountSheet()
            }
            .onReceive(launcherData.$launchedInstances) { value in
                launchedInstanceProcess = launcherData.launchedInstances[instance]
            }
            .onReceive(launcherData.$launchRequestedInstances) { value in
                if value.contains(where: { $0 == instance }) {
                    if launcherData.accountManager.currentSelected != nil {
                        sheetPrelaunch = true
                        downloadProgress.cancelled = false
                    } else {
                        sheetChooseAccount = true
                    }
                    
                    launcherData.launchRequestedInstances.removeAll {
                        $0 == instance
                    }
                }
            }
            .onReceive(launcherData.$editModeInstances) { value in
                if value.contains(where: { $0 == instance }) {
                    editingVM.start(from: instance)
                    
                } else if editingVM.inEditMode {
                    
                    editingVM.commit(
                        to: instance,
                        showNoNamePopover: $popoverNoName,
                        showDuplicateNamePopover: $popoverDuplicate,
                        data: launcherData
                    )
                }
            }
            .onReceive(launcherData.$killRequestedInstances) { value in
                if value.contains(where: { $0 == instance }) {
                    kill(launchedInstanceProcess!.process.processIdentifier, SIGKILL)
                    
                    launcherData.killRequestedInstances.removeAll {
                        $0 == instance
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func createPrelaunchSheet() -> some View {
        VStack {
            HStack {
                Spacer()
                
                Text(downloadMessage)
                
                Spacer()
            }
            .padding()
            
            if indeterminateProgress {
                ProgressView()
                    .progressViewStyle(.linear)
            } else {
                ProgressView(value: progress)
            }
            
            Button("Abort") {
                logger.info("Aborting instance launch")
                downloadSession?.invalidateAndCancel()
                sheetPrelaunch = false
                downloadProgress.cancelled = true
                downloadProgress = TaskProgress(current: 0, total: 1)
            }
            .onReceive(downloadProgress.$current) {
                progress = Float($0) / Float(downloadProgress.total)
            }
            .padding()
        }
        .task {
            onPrelaunchSheetAppear()
        }
        .padding(10)
    }
    
    func onPrelaunchSheetAppear() {
        logger.info("Preparing to launch \(instance.name)")
        indeterminateProgress = false
        downloadProgress.cancelled = false
        
        downloadMessage = "Downloading Libraries"
        logger.info("Downloading libraries")
        
        downloadSession = instance.downloadLibs(progress: downloadProgress) {
            downloadMessage = "Downloading Assets"
            logger.info("Downloading assets")
            
            downloadSession = instance.downloadAssets(progress: downloadProgress) {
                downloadMessage = "Extracting Natives"
                logger.info("Extracting natives")
                
                downloadProgress.callback = {
                    if !downloadProgress.cancelled {
                        indeterminateProgress = true
                        downloadMessage = "Authenticating with Minecraft"
                        logger.info("Fetching access token")
                        
                        Task(priority: .high) {
                            do {
                                let accessToken = try await launcherData.accountManager.selectedAccount.createAccessToken()
                                
                                DispatchQueue.main.async {
                                    withAnimation {
                                        let process = InstanceProcess(
                                            instance: instance,
                                            account: launcherData.accountManager.selectedAccount,
                                            accessToken: accessToken
                                        )
                                        
                                        launcherData.launchedInstances[instance] = process
                                        launchedInstanceProcess = process
                                        sheetPrelaunch = false
                                    }
                                }
                            } catch {
                                DispatchQueue.main.async {
                                    onPrelaunchError(.accessTokenFetch(error))
                                }
                            }
                        }
                    }
                    
                    downloadProgress.callback = {}
                }
                
                instance.extractNatives(progress: downloadProgress)
            } onError: {
                onPrelaunchError($0)
            }
        } onError: {
            onPrelaunchError($0)
        }
    }
    
    @MainActor
    func onPrelaunchError(_ error: LaunchError) {
        if sheetError {
            logger.debug("Suppressed error during prelaunch: \(error.localizedDescription)")
            
            if let sup = error.cause {
                logger.debug("Cause: \(sup.localizedDescription)")
            }
            
            return
        }
        
        logger.error("Caught error during prelaunch", error)
        
        ErrorTracker.instance.error("Caught error during prelaunch", error)
        
        if let cause = error.cause {
            logger.error("Cause", cause)
            
            ErrorTracker.instance.error("Causative error during prelaunch", error)
        }
        
        sheetPrelaunch = false
        sheetError = true
        downloadProgress.cancelled = true
        launchError = error
    }
}
