import SwiftUI

struct InstanceRuntimeView: View {
    @StateObject var instance: Instance
    @EnvironmentObject private var launcherData: LauncherData
    
    @State private var valid = false
    @State private var selectedJava: SavedJavaInstallation = .systemDefault
    
    var body: some View {
        VStack {
            Form {
                Toggle(isOn: $instance.preferences.runtime.valid) {
                    Text("Override default runtime settings")
                }
                .padding(.bottom, 5)
                
                Picker("Java", selection: $selectedJava) {
                    PickableJavaVersion(installation: .systemDefault)
                    
                    ForEach(launcherData.javaInstallations) {
                        PickableJavaVersion(installation: $0)
                    }
                }
                .disabled(!valid)
                
                Group {
                    TextField("Minimum Memory (MiB)", value: $instance.preferences.runtime.minMemory, formatter: NumberFormatter())
                    
                    TextField("Maximum Memory (MiB)", value: $instance.preferences.runtime.maxMemory, formatter: NumberFormatter())
                    
                    TextField("Default Java arguments", text: $instance.preferences.runtime.javaArgs)
                }
                .textFieldStyle(.roundedBorder)
                .disabled(!valid)
            }
            .padding(16)
            
            Spacer()
        }
        .task {            
            valid = instance.preferences.runtime.valid
            selectedJava = instance.preferences.runtime.defaultJava
        }
        .onChange(of: selectedJava) { newValue in
            instance.preferences.runtime.defaultJava = newValue
        }
        .onReceive(instance.preferences.runtime.$valid) {
            logger.debug("Changed runtime preferences validity for \(instance.name) to \($0)")
            
            if !$0 && valid {
                instance.preferences.runtime = .init(launcherData.globalPreferences.runtime).invalidate()
                selectedJava = launcherData.globalPreferences.runtime.defaultJava
            }
            
            valid = $0
        }
    }
}
