struct FabricMod: Decodable {
    let schemaVersion: Int
    let id: String
    let version: String
    let name: String
    let description: String
    let authors: [String]
    let contact: Contact
    let license: String
    let icon: String
    let environment: String
    let entrypoints: Entrypoints
    let mixins: [String]
    let accessWidener: String
    let depends: Dependencies
    
    struct Contact: Decodable {
        let homepage: String
        let sources: String
    }
    
    struct Entrypoints: Decodable {
        let main: [String]
        let client: [String]
        let jeiModPlugin: [String]
        
        enum CodingKeys: String, CodingKey {
            case main,
                 client,
                 jeiModPlugin = "jei_mod_plugin"
        }
    }
    
    struct Dependencies: Decodable {
        let fabricloader: String
        let fabricApi: String
        let minecraft: String
        let java: String
        
        enum CodingKeys: String, CodingKey {
            case fabricloader,
                 fabricApi = "fabric-api",
                 minecraft,
                 java
        }
    }
}
