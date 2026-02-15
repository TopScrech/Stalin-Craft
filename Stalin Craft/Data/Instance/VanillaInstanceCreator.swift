import Foundation

final class VanillaInstanceCreator: InstanceCreator {
    let name: String
    let versionUrl: URL
    let sha1: String
    let notes: String?
    let data: LauncherData
    
    init(name: String, versionUrl: URL, sha1: String, notes: String?, data: LauncherData) {
        self.name = name
        self.versionUrl = versionUrl
        self.sha1 = sha1
        self.notes = notes
        self.data = data
    }
    
    func install() throws -> Instance {
        let version = try Version.download(versionUrl, sha1: sha1)
        
        var libraries: [LibraryArtifact] = version.libraries
            .filter { lib in
                lib.rules?.allMatchRules(givenFeatures: [:]) ?? true
            }
            .map(\.downloads)
            .flatMap(\.artifacts)
        
        var arguments = version.arguments
        
        if let loggingConfig = version.logging {
            let path = loggingConfig.client.file.id
            
            libraries.append(.init(path: path, url: loggingConfig.client.file.url, sha1: loggingConfig.client.file.sha1, size: loggingConfig.client.file.size))
            
            arguments = arguments + .init(
                game: [],
                jvm: [.string("-Dlog4j.configurationFile=\(FileHandler.librariesFolder.appendingPathComponent(path).path)")]
            )
        }
        
        let mcJar = MinecraftJar(
            type: .remote,
            url: version.downloads.client.url,
            sha1: version.downloads.client.sha1
        )
        
        let logo = InstanceLogo(
            logoType: .builtin,
            string: "icon"
        )
        
        let instance = Instance(
            name: name,
            assetIndex: version.assetIndex,
            libraries: libraries,
            mainClass: version.mainClass,
            minecraftJar: mcJar,
            isStarred: false,
            logo: logo,
            description: notes,
            debugString: version.id,
            arguments: version.arguments
        )
        
        try instance.createAsNewInstance()
        
        logger.info("Successfully created vanilla instance \(self.name)")
        
        return instance
    }
}
