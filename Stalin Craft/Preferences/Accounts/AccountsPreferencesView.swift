import SwiftUI

struct AccountsPreferencesView: View {
    @StateObject private var msAccountVM = MicrosoftAccountVM()
    @EnvironmentObject private var launcherData: LauncherData
    
    @State private var cachedAccounts: [UUID: any MinecraftAccount] = [:]
    @State private var cachedAccountsOnly: [AdaptedAccount] = []
    @State private var selectedAccountIds: Set<UUID> = []
    
    @State private var sheetAddOffline = false
    
    var body: some View {
        VStack {
            Table(cachedAccountsOnly, selection: $selectedAccountIds) {
                TableColumn("Name", value: \.username)
                
                TableColumn("Type", value: \.type.rawValue)
                    .width(max: 100)
            }
            
            HStack {
                Spacer()
                
                Button("Add Offline Account") {
                    sheetAddOffline = true
                }
                .padding()
                
                Button("Add Microsoft Account") {
                    msAccountVM.prepareAndOpenSheet(launcherData: launcherData)
                }
                .padding()
                
                Button("Delete Selected") {
                    for id in selectedAccountIds {
                        launcherData.accountManager.accounts.removeValue(forKey: id)
                    }
                    
                    selectedAccountIds = []
                    
                    DispatchQueue.global(qos: .utility).async {
#warning("Handle error")
                        launcherData.accountManager.saveThrow()
                    }
                }
                .disabled(selectedAccountIds.isEmpty)
                .padding()
                
                Spacer()
            }
        }
        .task {
            cachedAccounts = launcherData.accountManager.accounts
            
            cachedAccountsOnly = Array(cachedAccounts.values).map { AdaptedAccount(from: $0)
            }
        }
        .onReceive(launcherData.accountManager.$accounts) {
            cachedAccounts = $0
            
            cachedAccountsOnly = Array($0.values).map {
                AdaptedAccount(from: $0)
            }
        }
        .onReceive(msAccountVM.$sheetMicrosoftAccount) {
            if !$0 {
                launcherData.accountManager.msAccountVM = nil
            }
        }
        .sheet($sheetAddOffline) {
            AddOfflineAccountView {
                let acc = OfflineAccount.createFromUsername($0)
                launcherData.accountManager.accounts[acc.id] = acc
                
                DispatchQueue.global(qos: .utility).async {
#warning("Handle error")
                    launcherData.accountManager.saveThrow()
                }
            }
        }
        .sheet($msAccountVM.sheetMicrosoftAccount) {
            HStack {
                if msAccountVM.error == .noError {
                    Text(msAccountVM.message)
                        .padding()
                } else {
                    VStack {
                        Text(msAccountVM.error.localizedDescription)
                            .padding()
                        
                        Button("Close") {
                            msAccountVM.closeSheet()
                        }
                        .padding()
                    }
                    .padding()
                }
            }
            .frame(idealWidth: 400)
        }
    }
}

#Preview {
    AccountsPreferencesView()
}

final class AdaptedAccount: Identifiable {
    var id: UUID
    var username: String
    var type: MinecraftAccountType
    
    init(from acc: any MinecraftAccount) {
        id = acc.id
        username = acc.username
        type = acc.type
    }
}
