import ScrechKit

struct WorldList: View {
    @StateObject var instance: Instance
    
    @FocusState var selectedWorld: World?
    
    private var savesFolder: String {
        instance.getSavesFolder().path
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(instance.worlds, id: \.self) { world in
                    WorldCard(world)
                        .environmentObject(instance)
                        .focusable()
                        .focused($selectedWorld, equals: world)
                        .highPriorityGesture(
                            TapGesture().onEnded {
                                selectedWorld = world
                            }
                        )
                }
            }
            
            Button {
                openInFinder(rootedAt: savesFolder)
            } label: {
                Text("Open in Finder")
            }
        }
        .task {
            instance.loadWorlds()
        }
    }    
}
