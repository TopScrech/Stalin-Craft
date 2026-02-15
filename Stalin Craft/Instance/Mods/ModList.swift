import ScrechKit

struct ModList: View {
    @StateObject var instance: Instance
    
    @State private var selected: Set<Mod> = []
    @State private var sortOrder: [KeyPathComparator<Mod>] = [
        .init(\.meta?.name, order: .forward)
    ]
    
    @State private var alertDelete = false
    
    var body: some View {
        VStack {
            Table(instance.mods, selection: $selected, sortOrder: $sortOrder) {
                TableColumn("Enabled") { mod in
                    Toggle("", isOn: .init {
                        mod.enabled
                    } set: { newValue in
                        guard let index = instance.mods.firstIndex(where: { $0.id == mod.id }) else {
                            return
                        }
                        
                        let fileManager = FileManager.default
                        let currentPath = instance.mods[index].path
                        var newPath = currentPath
                        
                        if newValue {
                            if currentPath.pathExtension == "disabled" {
                                let newName = currentPath.deletingPathExtension().lastPathComponent
                                
                                newPath = currentPath.deletingLastPathComponent().appendingPathComponent(newName)
                            }
                        } else {
                            newPath = currentPath.appendingPathExtension("disabled")
                        }
                        
                        do {
                            try fileManager.moveItem(at: currentPath, to: newPath)
                            
                            instance.mods[index].path = newPath
                            instance.mods[index].enabled = newValue
                        } catch {
                            logger.error("Failed to update mod file", error)
                        }
                    })
                }
                .width(50)
                
                TableColumn("Name") { mod in
                    Text(mod.meta?.name ?? mod.path.deletingPathExtension().lastPathComponent)
                        .foregroundStyle(mod.enabled ? .primary : Color.red)
                }
                
                TableColumn("Description") { mod in
                    Text(mod.meta?.description ?? "-")
                }
                
                TableColumn("Version") { mod in
                    Text(mod.meta?.version ?? "-")
                }
                
                TableColumn("File", value: \.path.lastPathComponent)
            }
            .animation(.default, value: instance.mods)
            .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                handleDrop(providers)
            }
            //        .onDeleteCommand {
            //            alertDelete = true
            //        }
            
            Button {
                openInFinderOrCreate(instance.getModsFolder().path)
            } label: {
                Text("Open in Finder")
            }
        }
        .task {
            instance.loadMods()
        }
        //        .alert("Delete", isPresented: $alertDelete) {
        //
        //        }
    }
}
