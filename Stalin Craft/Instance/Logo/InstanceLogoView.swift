import SwiftUI

struct InstanceLogoView: View {
    @StateObject var instance: Instance
    
    var body: some View {
        ZStack {
            if instance.logo.logoType == .file {
                AsyncImage(url: instance.getLogoPath()) {
                    $0.resizable().scaledToFit()
                } placeholder: {
                    Image(systemName: "tray.circle").resizable()
                }
            } else if instance.logo.logoType == .symbol {
                Image(systemName: instance.logo.string)
                    .resizable()
                    .scaledToFit()
            } else if instance.logo.logoType == .builtin {
                Image(instance.logo.string)
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}
