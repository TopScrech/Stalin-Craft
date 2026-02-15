import Foundation

final class InstanceProcess: ObservableObject {
    @Published var process = Process()
    @Published var logMessages: [String] = []
    @Published private var terminated = false
    
    init(instance: Instance, account: any MinecraftAccount, accessToken: String = "nou") {
        var maxMemory = setting(\.runtime.maxMemory)
        var minMemory = setting(\.runtime.minMemory)
        
        var javaInstallation = setting(\.runtime.defaultJava)
        
        if instance.preferences.runtime.valid {
            maxMemory = setting(\.runtime.maxMemory, for: instance)
            minMemory = setting(\.runtime.minMemory, for: instance)
            
            javaInstallation = setting(\.runtime.defaultJava, for: instance)
        }
        
        let javaExec = URL(fileURLWithPath: javaInstallation.javaExecutable)
        process.executableURL = javaExec
        process.currentDirectoryURL = instance.getGamePath()
        
        if !FileManager.default.fileExists(atPath: instance.getGamePath().path) {
            try? FileManager.default.createDirectory(at: instance.getGamePath(), withIntermediateDirectories: true)
        }
        
        var allArgs = [
            "-Xmx\(maxMemory)M",
            "-Xms\(minMemory)M",
            "-Djava.library.path=\(instance.getPath().appendingPathComponent("natives").path)"
        ]
        
        let classpath = "\(instance.getMcJarPath().path):\(instance.libraries.map { $0.getAbsolutePath().path }.joined(separator: ":"))"
        let mcArgs = ArgumentProvider()
        mcArgs.clientId(LauncherData.instance.accountManager.clientId)
        mcArgs.launcher(
            name: "Stalin Craft",
            version: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "dev"
        )
        mcArgs.xuid(account.xuid)
        mcArgs.username(account.username)
        mcArgs.version(instance.debugString)
        mcArgs.gameDir(instance.getGamePath())
        mcArgs.assetsDir(FileHandler.assetsFolder)
        mcArgs.nativesDir(instance.getNativesFolder().path)
        mcArgs.classpath(classpath)
        mcArgs.assetIndex(instance.assetIndex.id)
        mcArgs.uuid(account.id)
        mcArgs.accessToken(accessToken)
        mcArgs.userType("msa")
        mcArgs.versionType(LauncherData.instance.versionManifest.first(where: { $0.version == instance.debugString })?.type ?? "release")
        mcArgs.width(720)
        mcArgs.height(450)
        
        let processedJvmArgs = mcArgs.accept(instance.processArgsByRules(\.jvm, features: [:]))
        allArgs.append(contentsOf: processedJvmArgs)
        
        if !processedJvmArgs.contains("-cp") {
            allArgs.append("-cp")
            allArgs.append(classpath)
        }
        
        allArgs.append(instance.mainClass)
        
        let mcArgsProcessed = mcArgs.accept(instance.processArgsByRules(\.game, features: [:]))
        allArgs.append(contentsOf: mcArgsProcessed)
        
        process.arguments = allArgs
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        
        let outputHandler = outputPipe.fileHandleForReading
        
        outputHandler.readabilityHandler = { [weak self] pipe in
            guard let line = String(data: pipe.availableData, encoding: .utf8)?.trimmingCharacters(in: .newlines) else {
                return
            }
            
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                return
            }
            
            DispatchQueue.main.async {
                self?.logMessages.append(line)
            }
        }
        
        DispatchQueue.global(qos: .utility).async {
            self.process.launch()
            self.process.waitUntilExit()
            
            DispatchQueue.main.async {
                logger.debug("Instance \(instance.name) terminated")
                
                LauncherData.instance.launchedInstances.removeValue(forKey: instance)
            }
        }
        
        logger.info("Launching Instance \(instance.name)")
        
        logMessages.append("Stalin Craft: Launching Instance \(instance.name)")
    }
}

#warning("Unused")
//fileprivate extension Process {
//    func getRunCommand() -> String {
//        var command = launchPath ?? ""
//        
//        if let arguments {
//            for arg in arguments {
//                command += " \(arg)"
//            }
//        }
//        
//        return command
//    }
//}
