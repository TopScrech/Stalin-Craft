import SwiftUI

struct InstanceExportSheet: View {
    @StateObject var instance: Instance
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .center) {
            Button("Cancel") {
                dismiss()
            }
            .padding()
        }
    }
}
