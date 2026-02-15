import SwiftUI

struct InstanceSynopsisView: View {
    @StateObject var editingVM: InstanceEditingVM
    @StateObject var instance: Instance
    
    var body: some View {
        if editingVM.inEditMode {
            TextField("", text: $editingVM.synopsis, prompt: Text(instance.debugString))
                .fixedSize(horizontal: true, vertical: false)
                .caption()
                .padding(.vertical, 6)
                .foregroundColor(.gray)
                .frame(height: 10)
        } else {
            Text(instance.synopsisOrVersion)
                .caption()
                .padding(.vertical, 6)
                .foregroundColor(.gray)
                .frame(height: 10)
        }
    }
}
