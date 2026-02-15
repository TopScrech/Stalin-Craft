import SwiftUI

struct NewInstanceView: View {
    var body: some View {
        TabView {
            NewVanillaInstanceView()
                .tabItem {
                    Text("Vanilla")
                }
            //            TodoView()
            //                .tabItem {
            //                    Text("Modrinth")
            //                }
            //
            //            TodoView()
            //                .tabItem {
            //                    Text("Import")
            //                }
        }
        .border(.red, width: 0)
        .padding(14)
    }
}

#Preview {
    NewInstanceView()
}
