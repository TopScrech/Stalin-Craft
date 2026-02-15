import SwiftUI

struct MiscPreferencesView: View {
    @AppStorage("developerMode") var developerMode = true
    
    var body: some View {
        Form {
            Toggle("Developer Mode", isOn: $developerMode)
        }
        .padding(16)
    }
}

#Preview {
    MiscPreferencesView()
}
