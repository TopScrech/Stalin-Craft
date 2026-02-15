import Cocoa
import Zip

final class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Zip.addCustomFileExtension("jar")
    }
    
    //    func applicationWillFinishLaunching(_ notification: Notification) {
    //
    //    }
    //
    //    func applicationWillTerminate(_ aNotification: Notification) {
    //
    //    }
}
