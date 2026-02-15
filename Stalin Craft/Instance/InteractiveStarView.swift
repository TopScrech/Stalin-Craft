import SwiftUI

struct InteractiveStarView: View {
    @StateObject var instance: Instance
    
    @Binding var starHovered: Bool
    
    var body: some View {
        if instance.isStarred {
            Image(systemName: "star.fill")
                .resizable()
                .foregroundColor(starHovered ? .gray : .yellow)
                .onTapGesture {
                    withAnimation {
                        instance.isStarred = false
                    }
                }
                .frame(width: 16, height: 16)
        } else {
            Image(systemName: "star")
                .resizable()
                .foregroundColor(starHovered ? .yellow : .gray)
                .onTapGesture {
                    withAnimation {
                        instance.isStarred = true
                    }
                }
                .frame(width: 16, height: 16)
                .onHover { hoverValue in
                    withAnimation {
                        starHovered = hoverValue
                    }
                }
        }
    }
}
