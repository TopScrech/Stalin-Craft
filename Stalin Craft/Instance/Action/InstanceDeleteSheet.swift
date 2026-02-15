import SwiftUI

struct InstanceDeleteSheet: View {
    @EnvironmentObject private var launcherData: LauncherData
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedInstance: Instance?
    
    var instanceToDelete: Instance
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Authenticating with Microsoft")
            
            HStack {
                Button("Delete") {
                    if let index = launcherData.instances.firstIndex(of: instanceToDelete) {
                        if let selectedInstance {
                            if selectedInstance == instanceToDelete {
                                self.selectedInstance = nil
                            }
                        }
                        
                        let instance = launcherData.instances.remove(at: index)
                        
                        instance.delete()
                    }
                    
                    dismiss()
                }
                .padding()
                
                Button("Cancel") {
                    dismiss()
                }
                .padding()
            }
        }
        .padding(20)
    }
}
