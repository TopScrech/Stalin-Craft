import ScrechKit

struct InstanceSpecificCommands: View {
    @FocusedValue(\.selectedInstance) private var selectedInstance: Instance?
    
    @State private var instanceIsntSelected = true
    @State private var instanceStarred = false
    @State private var instanceIsntLaunched = true
    @State private var instanceIsntInEdit = true
    
    var body: some View {
        Button {
            if let instance = selectedInstance {
                withAnimation {
                    instance.isStarred = !instance.isStarred
                }
            }
        } label: {
            if instanceStarred {
                Text("Unstar")
                
                Image(systemName: "star.slash")
            } else {
                Text("Star")
                
                Image(systemName: "star")
            }
        }
        .disabled(selectedInstance == nil)
        .keyboardShortcut("f")
        .onChange(of: selectedInstance) { newValue in
            if let newValue {
                instanceStarred = newValue.isStarred
                instanceIsntLaunched = !LauncherData.instance.launchedInstances.contains(where: { $0.0 == newValue })
                instanceIsntInEdit = !LauncherData.instance.editModeInstances.contains(where: { $0 == newValue })
            } else {
                instanceStarred = false
                instanceIsntLaunched = true
                instanceIsntInEdit = true
            }
            
            instanceIsntSelected = newValue == nil
            
            logger.trace("\(selectedInstance?.name ?? "No instance") has been selected")
        }
        .onReceive(LauncherData.instance.$launchedInstances) { value in
            if let selectedInstance {
                instanceIsntLaunched = !value.contains(where: { $0.0 == selectedInstance })
            } else {
                instanceIsntLaunched = true
            }
        }
        .onReceive(LauncherData.instance.$editModeInstances) { value in
            if let selectedInstance {
                instanceIsntInEdit = !value.contains(where: { $0 == selectedInstance })
            } else {
                instanceIsntInEdit = true
            }
        }
        
        if instanceIsntLaunched {
            Button {
                LauncherData.instance.launchRequestedInstances.append(selectedInstance!)
            } label: {
                Text("launch")
                
                Image(systemName: "paperplane")
            }
            .keyboardShortcut(.return)
            .disabled(selectedInstance == nil)
        } else {
            Button {
                LauncherData.instance.killRequestedInstances.append(selectedInstance!)
            } label: {
                Text("kill")
                
                Image(systemName: "square.fill")
            }
        }
        
        if instanceIsntInEdit {
            Button {
                LauncherData.instance.editModeInstances.append(selectedInstance!)
            } label: {
                Text("Edit")
                
                Image(systemName: "pencil")
            }
            .keyboardShortcut(.init("e"))
            .disabled(selectedInstance == nil)
        } else {
            Button {
                LauncherData.instance.editModeInstances.removeAll {
                    $0 == selectedInstance!
                }
            } label: {
                Text("Save")
                
                Image(systemName: "checkmark")
            }
            .keyboardShortcut(.init("s"))
        }
        
        Button {
            openInFinderOrCreate(selectedInstance!.getPath().path)
        } label: {
            Text("Open in Finder")
            
            Image(systemName: "folder")
        }
        .keyboardShortcut(.upArrow)
        .disabled(selectedInstance == nil)
        
        if let selectedInstance {
            Divider()
                .onReceive(selectedInstance.$isStarred) { value in
                    instanceStarred = value
                }
        } else {
            Divider()
        }
    }
}
