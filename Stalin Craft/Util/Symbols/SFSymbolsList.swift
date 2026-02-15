import Foundation

struct SFSymbolsList {
    static func getAll() -> [String] {
        if #available(macOS 13, *) {
            return SFSymbols13List.getAll()
        }
        
        return SFSymbols12List.getAll()
    }
}
