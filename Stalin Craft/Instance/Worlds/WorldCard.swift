import ScrechKit

struct WorldCard: View {
    @EnvironmentObject private var instance: Instance
    
    private let world: World
    
    init(_ world: World) {
        self.world = world
    }
    
    var body: some View {
        let worldPath = instance.getSavesFolder().path + "/" + world.folder
        
        HStack {
            if let icon = loadIcon(worldPath.appending("/icon.png")) {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 64, height: 64)
                    .clipShape(.rect(cornerRadius: 8))
            }
            
            Text(world.folder)
            
            Button("Open") {
                openInFinder(rootedAt: worldPath)
            }
            
            if let size = formattedSize(worldPath) {
                Text(size)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func loadIcon(_ path: String) -> NSImage? {
        guard let imageData = FileManager.default.contents(atPath: path),
              let nsImage = NSImage(data: imageData) else {
            return nil
        }
        
        return nsImage
    }
    
    private func formattedSize(_ stringUrl: String) -> String? {
        if let url = URL(string: stringUrl) {
            let test = try! FileManager.default.allocatedSizeOfDirectory(url)
            
            return formatBytes(test)
        }
        
        return nil
    }
}

//#Preview {
//    WorldCard(.init(folder: ""))
//        .environmentObject(Instance())
//}
