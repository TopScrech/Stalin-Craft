import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject private var launcherData: LauncherData
    
    var body: some View {
        TabView(selection: $launcherData.selectedPreferenceTab) {
            RuntimePreferencesView()
                .tag(SettingsTab.runtime)
                .tabItem {
                    Label("Runtime", systemImage: "cup.and.saucer")
                }
            
            AccountsPreferencesView()
                .tag(SettingsTab.accounts)
                .tabItem {
                    Label("Accounts", systemImage: "person.circle")
                }
            
            ModToolsList()
                .tag(SettingsTab.modtools)
                .tabItem {
                    Label("Mod Tools", systemImage: "hammer")
                }
            
            UiPreferencesView()
                .tag(SettingsTab.ui)
                .tabItem {
                    Label("UI", systemImage: "paintbrush.pointed")
                }
            
            MiscPreferencesView()
                .tag(SettingsTab.misc)
                .tabItem {
                    Label("Misc", systemImage: "slider.horizontal.3")
                }
        }
        .task {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                launcherData.initializePreferenceListenerIfNot()
            }
        }
    }
}
