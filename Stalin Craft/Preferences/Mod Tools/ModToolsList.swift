import SwiftUI

struct ModToolsList: View {
    @State private var fabricVersions: [FabricVersion] = []
    
    @AppStorage("unstable_fabric_versions") private var unstableFabricVersions = true
    
    private var filteredFabricVersions: [FabricVersion] {
        if unstableFabricVersions {
            fabricVersions
        } else {
            fabricVersions.filter(\.stable)
        }
    }
    
    var body: some View {
        VStack {
            Toggle("Unstable versions", isOn: $unstableFabricVersions)
            
            List(filteredFabricVersions, id: \.version) { fabric in
                Text(fabric.version)
                    .foregroundStyle(fabric.stable ? .yellow : Color.primary)
            }
        }
        .task {
            getFabricVersions { versions in
                if let versions {
                    fabricVersions = versions
                } else {
                    logger.error("Failed to fetch or decode versions")
                }
            }
        }
    }
}

#Preview {
    ModToolsList()
}
