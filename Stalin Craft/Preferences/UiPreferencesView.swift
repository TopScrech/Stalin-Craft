import SwiftUI

struct UiPreferencesView: View {
    @EnvironmentObject private var launcherData: LauncherData
    
    var body: some View {
        Form {
            Toggle("Compact Instance List", isOn: $launcherData.globalPreferences.ui.compactList)
            
            Toggle("Compact Instance Logo", isOn: $launcherData.globalPreferences.ui.compactInstanceLogo)
        }
        .padding(16)
    }
}

#Preview {
    UiPreferencesView()
}
