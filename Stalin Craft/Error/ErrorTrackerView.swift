import SwiftUI

struct ErrorTrackerView: View {
    @StateObject var errorTracker: ErrorTracker
    
    init(_ errorTracker: ErrorTracker) {
        _errorTracker = StateObject(wrappedValue: errorTracker)
    }
    
    @State private var selection: ErrorTrackerEntry? = nil
    
    var body: some View {
        List(selection: $selection) {
            ForEach(errorTracker.errors, id: \.counter) { entry in
                HStack {
                    entry.type.icon
                    
                    VStack {
                        HStack {
                            Text(entry.description)
                                .padding(.bottom, 2)
                            
                            Spacer()
                        }
                        
                        if let error = entry.error {
                            HStack {
                                Text(error.localizedDescription)
                                
                                Spacer()
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(2)
            }
        }
    }
}

#Preview {
    let errorTracker = {
        let tracker = ErrorTracker()
        tracker.nonEssentialError(description: "Something happened!")
        tracker.error("Something bad happened!", LaunchError.errorDownloading(nil))
        tracker.nonEssentialError(description: "Something happened but it wasn't that bad")
        
        return tracker
    }()
    
    return ErrorTrackerView(errorTracker)
}
