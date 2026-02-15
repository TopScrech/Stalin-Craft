import WebKit

final class WebViewWindow: NSWindowController {
    static var current: WebViewWindow? = nil
    
    convenience init(url: URL) {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()
        
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 400, height: 600), configuration: config)
        webView.load(URLRequest(url: url))
        
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 400, height: 600), styleMask: [.titled, .closable], backing: .buffered, defer: false)
        window.contentView = webView
        window.title = NSLocalizedString("Login with Microsoft", comment: "no u")
        
        self.init(window: window)
        Self.current = self
    }
}
