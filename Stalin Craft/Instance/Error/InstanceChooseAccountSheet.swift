import SwiftUI

struct InstanceChooseAccountSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("No account")
                .padding()
            
            Button("Close") {
                dismiss()
            }
            .keyboardShortcut(.cancelAction)
            .padding()
        }
        .frame(minWidth: 200)
    }
}

#Preview {
    InstanceChooseAccountSheet()
}
