import Cocoa

final class ImgurSharingServiceDelegate: NSObject, NSSharingServicePickerDelegate {
    lazy var image = NSImage(named: "imgurIcon")!
    
    func sharingServicePicker(
        _ sharingServicePicker: NSSharingServicePicker,
        sharingServicesForItems items: [Any],
        proposedSharingServices proposedServices: [NSSharingService]
    ) -> [NSSharingService] {
        
        var share = proposedServices
        
        let imgurService = NSSharingService(title: "Imgur", image: image, alternateImage: image) {
            print("testing")
        }
        
        share.insert(imgurService, at: 0)
        
        return share
    }
}
