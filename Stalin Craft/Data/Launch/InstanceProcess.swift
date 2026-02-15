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
        
        var allArgs = [
            "-Xmx\(maxMemory)M",
            "-Xms\(minMemory)M",
            "-Djava.library.path=\(instance.getPath().appendingPathComponent("natives").path)"
        ]
        
#warning("Fix")
        allArgs.append(contentsOf: instance.processArgsByRules(\.jvm, features: [:]))
        
        let mcArgs = ArgumentProvider()
        mcArgs.clientId(LauncherData.instance.accountManager.clientId)
        mcArgs.xuid(account.xuid)
        mcArgs.username(account.username)
        mcArgs.version("todo")
        mcArgs.gameDir(instance.getGamePath())
        mcArgs.assetsDir(FileHandler.assetsFolder)
        mcArgs.nativesDir(instance.getNativesFolder().path)
        mcArgs.assetIndex(instance.assetIndex.id)
        mcArgs.uuid(account.id)
        mcArgs.accessToken(accessToken)
        mcArgs.userType("msa")
        mcArgs.versionType("todo")
        mcArgs.width(720)
        mcArgs.height(450)
        
        allArgs.append("-cp")
        instance.appendClasspath(args: &allArgs)
        allArgs.append(instance.mainClass)
        
#warning("Fix")
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
