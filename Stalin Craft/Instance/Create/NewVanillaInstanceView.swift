import SwiftUI

struct NewVanillaInstanceView: View {
    @EnvironmentObject private var launcherData: LauncherData
    
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("newVanillaInstance.cachedVersion") var cachedVersionId = ""
    @AppStorage("newVanillaInstance.cachedName") var name = ""
    
    @State private var versionManifest: [PartialVersion] = []
    @State private var showSnapshots = false
    @State private var showBeta = false
    @State private var showAlpha = false
    @State private var selectedVersion = PartialVersion.createBlank()
    @State private var versions: [PartialVersion] = []
    @State private var previouslySelectedVersionNames = Set<String>()
    
    @State private var popoverNoName = false
    @State private var popoverDuplicateName = false
    @State private var popoverInvalidVersion = false
    
    var body: some View {
        VStack {
            Spacer()
            
            Form {
                TextField("Name", text: $name)
                    .frame(width: 400, height: nil, alignment: .leading)
                    .textFieldStyle(.roundedBorder)
                    .popover(isPresented: $popoverNoName, arrowEdge: .bottom) {
                        Text("Enter a name")
                            .padding()
                    }
                    .popover(isPresented: $popoverDuplicateName, arrowEdge: .bottom) {
#warning("implement")
                        Text("Enter a unique name")
                            .padding()
                    }
                Picker("Version", selection: $selectedVersion) {
                    ForEach(versions) { ver in
                        Text(ver.version)
                            .tag(ver)
                    }
                }
                .popover(isPresented: $popoverInvalidVersion, arrowEdge: .bottom) {
                    Text("Choose a valid version")
                        .padding()
                }
                
                Toggle("Show snapshots", isOn: $showSnapshots)
                
                Toggle("Show old beta", isOn: $showBeta)
                
                Toggle("Show old alpha", isOn: $showAlpha)
            }
            .padding()
            
            HStack {
                Spacer()
                
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .keyboardShortcut(.cancelAction)
                    
                    Button("Done") {
                        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if trimmedName.isEmpty {
#warning("Also check for spaces")
                            popoverNoName = true
                            return
                        }
                        
                        if launcherData.instances.map(\.name).contains(where: { $0.localizedStandardContains(trimmedName) }) {
                            popoverDuplicateName = true
                            return
                        }
                        
                        if !versionManifest.contains(where: { $0 == selectedVersion }) {
                            popoverInvalidVersion = true
                            return
                        }
                        
                        popoverNoName = false
                        popoverDuplicateName = false
                        popoverInvalidVersion = false
                        
                        let instance = VanillaInstanceCreator(
                            name: trimmedName, 
                            versionUrl: URL(string: selectedVersion.url)!,
                            sha1: selectedVersion.sha1,
                            notes: nil,
                            data: launcherData
                        )
                        
                        do {
                            launcherData.instances.append(try instance.install())
                            name = selectedVersion.version
                            previouslySelectedVersionNames.insert(selectedVersion.version)
                            cachedVersionId = ""
                            dismiss()
                            
                        } catch {
                            ErrorTracker.instance.error("Error creating instance", error)
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                }
                .padding([.trailing, .bottom])
            }
        }
        .task {
            versionManifest = launcherData.versionManifest
            
            if !cachedVersionId.isEmpty {
                previouslySelectedVersionNames.insert(cachedVersionId)
            }
            
            recomputeVersions()
        }
        .onReceive(launcherData.$versionManifest) {
            versionManifest = $0
            recomputeVersions()
        }
        .onChange(of: showAlpha) {
            recomputeVersions()
        }
        .onChange(of: showBeta) {
            recomputeVersions()
        }
        .onChange(of: showSnapshots) {
            recomputeVersions()
        }
        .onChange(of: selectedVersion) { _, newValue in
            cachedVersionId = newValue.version
            applyDefaultName(for: newValue.version)
        }
    }
    
    func applyDefaultName(for version: String) {
        if shouldFollowSelectedVersionName {
            name = version
        }
        
        if version != PartialVersion.createBlank().version {
            previouslySelectedVersionNames.insert(version)
        }
    }
    
    var shouldFollowSelectedVersionName: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty {
            return true
        }
        
        let fallbackDefaultName = NSLocalizedString("New Instance", comment: "New Instance")
        let normalized = trimmedName.lowercased()
        
        if normalized == fallbackDefaultName.lowercased() || normalized == "new instance" {
            return true
        }
        
        if previouslySelectedVersionNames.contains(trimmedName) {
            return true
        }
        
        if versions.contains(where: { $0.version == trimmedName }) {
            return true
        }
        
        return false
    }
    
    func recomputeVersions() {
        if versionManifest.isEmpty {
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            let newVersions = versionManifest
                .filter { version in
                    return version.type == "old_alpha" && showAlpha ||
                    version.type == "old_beta" && showBeta ||
                    version.type == "snapshot" && showSnapshots ||
                    version.type == "release"
                }
            
            let notContained = !newVersions.contains(selectedVersion)
            
            DispatchQueue.main.async {
                versions = newVersions
                
                if let cached = versions.filter({ $0.version == cachedVersionId }).first {
                    selectedVersion = cached
                } else if notContained {
                    selectedVersion = newVersions.first!
                }
                
                applyDefaultName(for: selectedVersion.version)
            }
        }
    }
}

#Preview {
    NewVanillaInstanceView()
}
