import ScrechKit

struct ContentView: View {
    @EnvironmentObject private var launcherData: LauncherData
    
    private static let nullUuid = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    
    @State private var searchTerm = ""
    @State private var starredOnly = false
    @State private var isSidebarHidden = false
    @State private var selectedInstance: Instance? = nil
    @State private var selectedAccount = ContentView.nullUuid
    @State private var cachedAccounts: [AdaptedAccount] = []
    
    @State private var sheetCreate = false
    @State private var sheetDuplicate = false
    @State private var sheetDelete = false
    @State private var sheetExport = false
    
    var body: some View {
        NavigationView {
            VStack {
                if !launcherData.instances.isEmpty {
                    TextField("Search", text: $searchTerm)
                        .padding(.trailing, 8)
                        .padding(.leading, 10)
                        .padding([.top, .bottom], 9)
                        .textFieldStyle(.roundedBorder)
                }
                
                List(selection: $selectedInstance) {
                    ForEach(launcherData.instances) { instance in
                        if (!starredOnly || instance.isStarred) && instance.matchesSearchTerm(searchTerm) {
                            InstanceNavigationLink(
                                instance: instance,
                                selectedInstance: $selectedInstance
                            )
                            .tag(instance)
                            .padding(4)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .onMove { indices, newOffset in
                        launcherData.instances.move(fromOffsets: indices, toOffset: newOffset)
                    }
                }
                .overlay {
                    if #available(macOS 14, *) {
                        if launcherData.instances.isEmpty {
                            ContentUnavailableView("No instances found", systemImage: "hammer", description: Text("Try pyzh"))
                        }
                    }
                }
                .toolbar {
                    ToolbarItemGroup {
                        createSidebarToolbar()
                    }
                }
            }
            .sheet($sheetCreate) {
                NewInstanceView()
            }
            .sheet($sheetDelete) {
                InstanceDeleteSheet(
                    selectedInstance: $selectedInstance,
                    instanceToDelete: selectedInstance!
                )
            }
            .sheet($sheetDuplicate) {
                InstanceDuplicationSheet(instance: selectedInstance!)
            }
            .sheet($sheetExport) {
                InstanceExportSheet(instance: selectedInstance!)
            }
            .onReceive(launcherData.$instances) { newValue in
                if let selectedInstance {
                    if !newValue.contains(where: { $0 == selectedInstance }) {
                        self.selectedInstance = nil
                    }
                }
            }
            .navigationTitle("Instances")
            
            Text("Select an Instance")
                .largeTitle()
                .foregroundColor(.gray)
        }
        .bindInstanceFocusValue(selectedInstance)
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            for provider in providers {
                _ = provider.loadObject(ofClass: URL.self) { folderURL, error in
                    
                    if let error {
                        logger.error("Error importing an instance", error)
                    }
                    
                    guard let folderURL else {
                        return
                    }
                    
                    print("Dropped folder URL: \(folderURL)")
                    let destinationURL = FileHandler.instancesFolder
                    
                    do {
                        let fileManager = FileManager.default
                        let destinationFolderURL = destinationURL.appendingPathComponent(folderURL.lastPathComponent)
                        
                        // Check if destination folder exists
                        if fileManager.fileExists(atPath: destinationFolderURL.path) {
                            try fileManager.removeItem(at: destinationFolderURL)
                        }
                        
                        // Copy folder to destination
                        try fileManager.copyItem(at: folderURL, to: destinationFolderURL)
                        print("Folder successfully copied to \(FileHandler.instancesFolder)")
                        
                        do {
                            let newInstance = try Instance.loadFromDirectory(folderURL)
                            
                            newInstance.name = folderURL.deletingPathExtension().lastPathComponent
                            
                            main {
                                launcherData.instances.append(newInstance)
                            }
                        } catch {
                            logger.error("Invalid instance imported")
                            
                            ErrorTracker.instance.error("Invalid instance imported \(folderURL)", error)
                            
                            logger.notice("Disabling invalid instance at \(folderURL.path)")
                            
                            try FileManager.default.moveItem(
                                at: folderURL,
                                to: folderURL.appendingPathExtension("_old")
                            )
                        }
                    } catch {
                        print("Error copying folder: \(error)")
                    }
                }
            }
            
            return true
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                createTrailingToolbar()
            }
            
            ToolbarItemGroup(placement: .primaryAction) {
                createPrimaryToolbar()
            }
        }
    }
    
    @ViewBuilder
    func createSidebarToolbar() -> some View {
        Spacer()
        
        Button {
            NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        } label: {
            Image(systemName: "sidebar.leading")
        }
        
        Toggle(isOn: $starredOnly) {
            Image(systemName: starredOnly ? "star.fill" : "star")
        }
        .help("Show starred instances")
        
        Button {
            sheetCreate = true
        } label: {
            Image(systemName: "plus")
        }
        .onReceive(launcherData.$newInstanceRequested) { req in
            if req {
                sheetCreate = true
                launcherData.newInstanceRequested = false
            }
        }
    }
    
    @ViewBuilder
    func createPrimaryToolbar() -> some View {
        Button {
            sheetDelete = true
        } label: {
            Image(systemName: "trash")
        }
        .disabled(selectedInstance == nil)
        .help("Delete")
        
        Button {
            sheetDuplicate = true
        } label: {
            Image(systemName: "doc.on.doc")
        }
        .disabled(selectedInstance == nil)
        .help("Duplicate")
        
        Button {
            sheetExport = true
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
        .disabled(true)
        .help("Share or Export")
        
        Button {
            if launcherData.launchedInstances.contains(where: { $0.0 == selectedInstance! }) {
                launcherData.killRequestedInstances.append(selectedInstance!)
            } else {
                launcherData.launchRequestedInstances.append(selectedInstance!)
            }
        } label: {
            if let selectedInstance {
                if launcherData.launchedInstances.contains(where: { $0.0 == selectedInstance }) {
                    Image(systemName: "square.fill")
                } else {
                    Image(systemName: "arrowtriangle.forward.fill")
                }
            } else {
                Image(systemName: "arrowtriangle.forward.fill")
            }
        }
        .disabled(selectedInstance == nil)
        .help("launch")
        
        Button {
            if launcherData.editModeInstances.contains(where: { $0 == selectedInstance! }) {
                launcherData.editModeInstances.removeAll {
                    $0 == selectedInstance!
                }
            } else {
                launcherData.editModeInstances.append(selectedInstance!)
            }
        } label: {
            if let selectedInstance {
                if launcherData.editModeInstances.contains(where: { $0 == selectedInstance }) {
                    Image(systemName: "checkmark")
                } else {
                    Image(systemName: "pencil")
                }
            } else {
                Image(systemName: "pencil")
            }
        }
        .disabled(selectedInstance == nil)
        .help("Edit")
    }
    
    @ViewBuilder
    func createTrailingToolbar() -> some View {
        Spacer()
        
        Picker("Account", selection: $selectedAccount) {
            Text("No account")
                .tag(ContentView.nullUuid)
            
            ForEach(cachedAccounts) { value in
                HStack(alignment: .center) {
                    AsyncImage(url: URL(string: "https://crafatar.com/avatars/" + value.id.uuidString + "?overlay&size=16"), scale: 1, content: { $0 }) {
                        Image("steve")
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                    
                    Text(value.username)
                }
                .background(.ultraThickMaterial)
                .padding()
                .tag(value.id)
            }
        }
        .frame(height: 40)
        .task {
            selectedAccount = launcherData.accountManager.currentSelected ?? ContentView.nullUuid
            
            cachedAccounts = Array(launcherData.accountManager.accounts.values).map {
                .init(from: $0)
            }
        }
        .onReceive(launcherData.accountManager.$currentSelected) {
            selectedAccount = $0 ?? ContentView.nullUuid
        }
        .onChange(of: selectedAccount) { newValue in
            launcherData.accountManager.currentSelected = newValue == ContentView.nullUuid ? nil : newValue
            
            DispatchQueue.global(qos: .utility).async {
                launcherData.accountManager.saveThrow()
            }
        }
        .onReceive(launcherData.accountManager.$accounts) {
            cachedAccounts = Array($0.values).map {
                .init(from: $0)
            }
        }
        
        Button {
            launcherData.selectedPreferenceTab = .accounts
            
            if #available(macOS 13, *) {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            } else {
                NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
            }
        } label: {
            Image(systemName: "person.circle")
        }
        .help("Manage Accounts")
    }
}

fileprivate extension NavigationView {
    @ViewBuilder
    func bindInstanceFocusValue(_ i: Instance?) -> some View {
        if #available(macOS 13, *) {
            self.focusedValue(\.selectedInstance, i)
        } else {
            self
        }
    }
}
