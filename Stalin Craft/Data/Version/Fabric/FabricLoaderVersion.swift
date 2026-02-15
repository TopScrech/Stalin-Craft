struct FabricLoaderVersion: Codable {
    let separator: String
    let build: Int
    let maven: String
    let version: String
    let stable: Bool
}
