import SwiftUI

struct ScreenshotShareButton: NSViewRepresentable {
    var selectedItem: Screenshot?
    
    func makeNSView(context: Context) -> NSButton {
        let button = NSButton(
            title: NSLocalizedString("Share", comment: "Share"),
            target: context.coordinator, 
            action: #selector(Coordinator.buttonClicked)
        )
        
        context.coordinator.button = button
        
        button.bezelStyle = .rounded
        button.controlSize = .regular
        button.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .regular))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return button
    }
    
    func updateNSView(_ nsView: NSButton, context: Context) {
        context.coordinator.selectedItem = selectedItem
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(selectedItem: selectedItem)
    }
    
    final class Coordinator: NSObject {
        let delegate = ImgurSharingServiceDelegate()
        var selectedItem: Screenshot?
        var button: NSButton?
        
        init(selectedItem: Screenshot?) {
            self.selectedItem = selectedItem
            super.init()
        }
        
        @objc func buttonClicked() {
            guard let selectedItem else {
                return
            }
            
            let sharingItems = [selectedItem.path as Any]
            
            let sharingServicePicker = NSSharingServicePicker(items: sharingItems)
            sharingServicePicker.delegate = delegate
            sharingServicePicker.show(relativeTo: .zero, of: button!, preferredEdge: .minY)
        }
    }
}
