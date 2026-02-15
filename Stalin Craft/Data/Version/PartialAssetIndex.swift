struct PartialAssetIndex: Codable, Equatable {
    static let none = PartialAssetIndex(id: "none", sha1: "", url: "")
    let id: String
    let sha1: String
    let url: String
    
    func `default`(fallback: PartialAssetIndex) -> PartialAssetIndex {
        self == .none ? fallback : self
    }
}
