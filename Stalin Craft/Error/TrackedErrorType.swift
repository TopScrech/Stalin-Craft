import SwiftUI

enum TrackedErrorType {
    case nonEssentialError,
         error
    
    @ViewBuilder
    var icon: some View {
        switch(self) {
        case .nonEssentialError:
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.yellow)
                .frame(width: 48, height: 48)
            
        case .error:
            ZStack {
                Image(systemName: "square.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.red)
                    .frame(width: 48, height: 48)
            }
            .frame(width: 48, height: 48)
        }
    }
}
