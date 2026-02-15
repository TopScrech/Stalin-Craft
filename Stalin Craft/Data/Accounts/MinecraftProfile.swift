struct MinecraftProfile: Codable {
    let id: String
    let name: String
    let skins: [Skin]
    
    struct Skin: Codable {
        let id: String
        let state: String
        let url: String
        let variant: String
    }
    
    func activeSkin() -> Skin? {
        skins.first(where: {
            $0.state == "ACTIVE"
        })
    }
}
