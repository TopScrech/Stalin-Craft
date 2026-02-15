import SwiftUI

struct InstanceInterativeLogoView: View {
    @StateObject var instance: Instance
    @EnvironmentObject private var launcherData: LauncherData
    
    @Binding var sheetLogo: Bool
    @Binding var logoHovered: Bool
    
    private var size: CGFloat {
        launcherData.globalPreferences.ui.compactInstanceLogo ? 64 : 128
    }
    
    var body: some View {
        InstanceLogoView(instance: instance)
            .frame(width: size, height: size)
            .padding(20)
            .opacity(logoHovered ? 0.75 : 1)
            .onHover { value in
                withAnimation {
                    logoHovered = value
                }
            }
            .onTapGesture {
                sheetLogo = true
            }
    }
}
