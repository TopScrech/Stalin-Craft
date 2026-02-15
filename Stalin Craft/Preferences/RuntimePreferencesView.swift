import SwiftUI

struct RuntimePreferencesView: View {
    @EnvironmentObject private var launcherData: LauncherData
    
    @State private var cachedDefaultJava = SavedJavaInstallation.systemDefault
    @State private var showFileImporter = false
    
    var body: some View {
        VStack {            
            Form {
                Text(cachedDefaultJava.javaExecutable)
                    .frame(alignment: .center)
                    .foregroundColor(.secondary)
                
                TextField("Minimum Memory (MiB)", value: $launcherData.globalPreferences.runtime.minMemory, formatter: NumberFormatter())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Maximum Memory (MiB)", value: $launcherData.globalPreferences.runtime.maxMemory, formatter: NumberFormatter())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Default Java arguments", text: $launcherData.globalPreferences.runtime.javaArgs)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textFieldStyle(.roundedBorder)
            }
            .task {
                cachedDefaultJava = launcherData.globalPreferences.runtime.defaultJava
            }
            .onReceive(launcherData.globalPreferences.runtime.$defaultJava) {
                cachedDefaultJava = $0
                logger.debug("Default java runtime changed to \($0.javaExecutable)")
            }
            .padding([.leading, .trailing, .top], 16.0)
            .padding(.bottom, 5)
            
            Table(of: SavedJavaInstallation.self, selection: .init {
                launcherData.globalPreferences.runtime.defaultJava
            } set: {
                launcherData.globalPreferences.runtime.defaultJava = $0 ?? SavedJavaInstallation.systemDefault
            }) {
                TableColumn("Version") {
                    Text($0.getDebugString())
                }
                .width(max: 200)
                
                TableColumn("Path", value: \.javaExecutable)
            } rows: {
                TableRow(SavedJavaInstallation.systemDefault)
                
                ForEach(launcherData.javaInstallations) {
                    TableRow($0)
                }
            }
            .padding([.leading, .trailing, .bottom])
            .padding(.top, 4)
            
            Button("Add Java Version") {
                showFileImporter = true
            }
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.unixExecutable, .executable, .exe]) { result in
                let url: URL
                
                do {
                    url = try result.get()
                    
                } catch {
                    logger.error("Error importing java runtime: \(error.localizedDescription)")
                    return
                }
                
                let install = SavedJavaInstallation(javaExecutable: url.path)
                install.setupAsNewVersion(launcherData: launcherData)
                
                logger.info("Set up java runtime from \(install.javaExecutable)")
            }
        }
    }
}

struct PickableJavaVersion: View {
    let installation: SavedJavaInstallation
    
    var body: some View {
        Text(installation.getString())
            .tag(installation)
    }
}

#Preview {
    RuntimePreferencesView()
}
