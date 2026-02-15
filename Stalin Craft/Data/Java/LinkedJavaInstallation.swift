import Foundation

final class LinkedJavaInstallation: Codable {
    let JVMArch:            String
    let JVMBundleID:        String
    let JVMEnabled:         Bool
    let JVMHomePath:        String
    let JVMName:            String
    let JVMPlatformVersion: String
    let JVMVendor:          String
    let JVMVersion:         String
}

extension LinkedJavaInstallation {
    private static let decoder: PropertyListDecoder = PropertyListDecoder()
    
    static func getAll() throws -> [LinkedJavaInstallation] {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/libexec/java_home")
        p.arguments = ["-X"]
        
        let pipe = Pipe()
        p.standardOutput = pipe
        p.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let installations = try decoder.decode([LinkedJavaInstallation].self, from: data)
        
        return installations
    }
}
