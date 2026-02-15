//import XCTest
//import InnateKit
//
//class DownloadTests: XCTestCase {
//    private var manifest: [ManifestVersion] = []
//    
//    override func setUpWithError() throws {
//        try FileManager.default.removeItem(at: FileHandler.assetsFolder)
//        let _ = try FileHandler.getOrCreateFolder("Assets")
//        manifest = try VersionManifest.download()
//    }
//    
//    override func tearDownWithError() throws {
//        manifest = []
//    }
//    
//    func testDownloadVersionManifest() throws {
//        measure {
//            let _ = try! VersionManifest.download()
//        }
//    }
//    
//    func testDownloadVersion() throws {
//        measure {
//            let manifestVer = manifest.randomElement()!
//            let _ = try! Version.download(manifestVer.url, sha1: manifestVer.sha1)
//            print(manifestVer.url)
//        }
//    }
//    
//    func testDownloadAssets() throws {
//        let manifestVer = manifest.randomElement()!
//        let version = try Version.download(manifestVer.url, sha1: manifestVer.sha1)
//        let assetIndex = try AssetIndex.get(version: manifestVer.version, urlStr: version.assetIndex.url)
//        let progress: DownloadProgress = DownloadProgress(current: 0, total: 1)
//        try assetIndex.downloadParallel(progress: progress, callback: {})
//        while (!progress.isDone()) {
//            print(progress.current)
//            print(progress.total)
//            Thread.sleep(forTimeInterval: 2)
//        }
//    }
//    
//    func testDownloadLibraries() throws {
//        let manifestVer = manifest.randomElement()!
//        let version = try Version.download(manifestVer.url, sha1: manifestVer.sha1)
//        let progress: DownloadProgress = version.downloadLibraries()
//        while (!progress.isDone()) {
//            print(progress.current)
//            print(progress.total)
//            Thread.sleep(forTimeInterval: 2)
//        }
//    }
//}
