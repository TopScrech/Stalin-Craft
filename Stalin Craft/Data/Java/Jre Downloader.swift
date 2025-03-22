import Foundation

final class JreDownloader {
    static func download(version: Int) throws {
        // let url = URL(string: getUrl(version: version))!
        // let data = try Data(contentsOf: url)
    }
    
    private static func getUrl(version: Int) -> String {
        "https://api.adoptium.net/v3/binary/latest/\(version)/ga/mac/\(formattedArchitecture)/jre/hotspot/normal/eclipse"
    }
    
    private static var architecture: String {
        var sysinfo = utsname()
        let result = uname(&sysinfo)
        
        guard result == EXIT_SUCCESS else {
            fatalError()
        }
        
        let data = Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN))
        
        guard let identifier = String(bytes: data, encoding: .ascii) else {
            fatalError()
        }
        
        return identifier.trimmingCharacters(in: .controlCharacters)
    }
    
    private static var formattedArchitecture: String {
        architecture.localizedStandardContains("arm") ? "aarch64" : "x86_64"
    }
}
