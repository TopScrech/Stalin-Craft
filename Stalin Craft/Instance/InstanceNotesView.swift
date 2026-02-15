import SwiftUI

struct InstanceNotesView: View {
    @StateObject var editingVM: InstanceEditingVM
    @StateObject var instance: Instance
    
    var body: some View {
        if editingVM.inEditMode {
            TextField("", text: $editingVM.notes, prompt: Text("Notes"))
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .frame(minWidth: 50)
                .padding(.leading, 3)
        } else {
            if instance.notes != nil {
                Text(instance.notes!)
                    .frame(minWidth: 50)
                    .padding(.leading, 3)
            }
        }
    }
}
