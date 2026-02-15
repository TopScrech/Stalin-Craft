import Foundation

final class DownloadTask {
    let sourceUrl: URL
    let filePath: URL
    let sha1: String?
    
    init(sourceUrl: URL, filePath: URL, sha1: String?) {
        self.sourceUrl = sourceUrl
        self.filePath = filePath
        self.sha1 = sha1
    }
}
