import SwiftUI

/// A simple and cross-platform SFSymbol picker for SwiftUI.
struct SymbolPicker: View {
    @Environment(\.presentationMode) private var presentationMode
    
    private let symbols = SFSymbolsList.getAll()
    
    private let symbolSize: CGFloat = 24
    private let gridDimension: CGFloat = 48
    private let symbolCornerRadius: CGFloat = 8
    private let unselectedItemBackgroundColor: Color = .clear
    private let selectedItemBackgroundColor: Color = .accentColor
    private let ackgroundColor: Color = .clear
    
    // MARK: - Properties
    @Binding var symbol: String
    
    @State private var searchText = ""
    
    // MARK: - Public Init
    /// Initializes `SymbolPicker` with a string binding that captures the raw value of
    /// user-selected SFSymbol.
    /// - Parameter symbol: String binding to store user selection.
    init(_ symbol: Binding<String>) {
        _symbol = symbol
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var searchableSymbolGrid: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Search", text: $searchText)
                    .textFieldStyle(.plain)
                    .fontSize(18)
                    .disableAutocorrection(true)
                
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 16, height: 16)
                }
                .buttonStyle(.borderless)
            }
            .padding()
            
            Divider()
            
            symbolGrid
        }
    }
    
    private var symbolGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: gridDimension, maximum: gridDimension))]) {
                ForEach(symbols.filter { searchText.isEmpty ? true : $0.localizedCaseInsensitiveContains(searchText) }, id: \.self) { thisSymbol in
                    Button {
                        symbol = thisSymbol
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        if thisSymbol == symbol {
                            Image(systemName: thisSymbol)
                                .fontSize(symbolSize)
                                .frame(maxWidth: .infinity, minHeight: gridDimension)
                                .background(selectedItemBackgroundColor)
                                .cornerRadius(symbolCornerRadius)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: thisSymbol)
                                .fontSize(symbolSize)
                                .frame(maxWidth: .infinity, minHeight: gridDimension)
                                .background(unselectedItemBackgroundColor)
                                .cornerRadius(symbolCornerRadius)
                                .foregroundColor(.primary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    var body: some View {
        searchableSymbolGrid
            .frame(width: 540, height: 320, alignment: .center)
    }
}

#Preview {
    SymbolPicker(.constant("square.and.arrow.up"))
}
