import SwiftUI

struct InstanceLogoSheet: View {
    @StateObject var instance: Instance
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            TabView {
                ImageLogoPickerView(instance: instance)
                    .tabItem {
                        Text("Image")
                    }
                
                SymbolLogoPickerView(instance: instance, logo: $instance.logo)
                    .tabItem {
                        Text("Symbol")
                    }
            }
            
            Button("Done") {
                withAnimation {
                    dismiss()
                }
            }
            .padding()
            .keyboardShortcut(.cancelAction)
        }
        .padding(15)
    }
}
