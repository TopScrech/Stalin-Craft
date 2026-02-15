import SwiftUI

struct SymbolLogoPickerView: View {
    var instance: Instance
    
    @Binding var logo: InstanceLogo
    
    var body: some View {
        SymbolPicker(.init {
            if logo.logoType == .file {
                return ""
            }
            
            return logo.string
        } set: {
            logo = InstanceLogo(logoType: .symbol, string: $0)
            
            DispatchQueue.global().async {
                try! instance.save()
            }
        })
    }
}
