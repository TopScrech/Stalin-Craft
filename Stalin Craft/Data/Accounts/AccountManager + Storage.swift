import Foundation

extension AccountManager {
    static func load() throws -> AccountManager {
        let manager = AccountManager()
        
#warning("Error handling")
        if let data = try FileHandler.getData(AccountManager.accountsPath) {
            let plist = try PropertyListSerialization.propertyList(from: data, format: nil) as! [String: Any]
            
            var currentSelected: UUID? = nil
            
            if let currentSelectedE = plist["Current"] as? String {
                currentSelected = UUID(uuidString: currentSelectedE)!
            }
            
            let accounts = plist["Accounts"] as! [String:[String: Any]]
            var deserializedAccounts: [UUID:any MinecraftAccount] = [:]
            
            for (_, account) in accounts {
                let type = account["type"] as! String
                
                if type == "Offline" {
                    let acc = OfflineAccount.createFromDict(account)
                    deserializedAccounts[acc.id] = acc
                } else if type == "Microsoft" {
                    let acc = MicrosoftAccount.createFromDict(account)
                    deserializedAccounts[acc.id] = acc
                }
            }
            
            if let e = currentSelected {
                if !deserializedAccounts.keys.contains(e) {
                    currentSelected = nil
                }
            }
            
            manager.currentSelected = currentSelected
            manager.accounts = deserializedAccounts
        }
        
        logger.debug("Loaded \(manager.accounts.count) accounts")
        
        return manager
    }
    
    func saveThrow() {
        let encoder = PropertyListEncoder()
        var plist: [String: Any] = [:]
        
        if let currentSelected {
            plist["Current"] = currentSelected.uuidString
        }
        
        var accounts: [String: Any] = [:]
        
        for (thing, account) in self.accounts {
            accounts[thing.uuidString] = try! PropertyListSerialization.propertyList(from: try encoder.encode(account), format: nil)
        }
        
        plist["Accounts"] = accounts
        try! FileHandler.saveData(AccountManager.accountsPath, PropertyListSerialization.data(fromPropertyList: plist, format: .binary, options: 0))
    }
}
