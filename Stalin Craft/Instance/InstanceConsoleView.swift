import ScrechKit

struct InstanceConsoleView: View {
    @EnvironmentObject private var launcherData: LauncherData
    
    var instance: Instance
    
    @Binding var launchedInstanceProcess: InstanceProcess?
    
    @State private var launchedInstances: [Instance: InstanceProcess]? = nil
    @State private var logMessages: [String] = []
    @State private var search = ""
    
    private var filteredLogs: [String] {
        if search.isEmpty {
            logMessages
        } else {
            logMessages.filter {
                $0.contains(search)
            }
        }
    }
    
    var body: some View {
        VStack {
            TextField("Search", text: $search)
                .textFieldStyle(.roundedBorder)
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(filteredLogs, id: \.self) { message in
                            Text(message)
                                .font(.system(.body, design: .monospaced))
                                .id(message)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .id(logMessages)
                }
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.secondary, lineWidth: 1)
                }
                .padding(7)
                
                HStack {
                    Button("Open logs folder") {
                        openInFinderOrCreate(instance.getLogsFolder().path)
                    }
                }
                .padding([.top, .leading, .trailing], 5)
                
                if launchedInstanceProcess != nil {
                    ZStack {
                        
                    }
                    .task {
                        withAnimation {
                            proxy.scrollTo(logMessages.last, anchor: .bottom)
                        }
                        
                        logMessages = launchedInstanceProcess!.logMessages
                    }
                    .onReceive(launchedInstanceProcess!.$logMessages) {
                        logMessages = $0
                    }
                }
            }
            
            Spacer()
        }
    }
}
