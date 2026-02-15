import Foundation

struct FabricVersion: Decodable {
    var url: String
    var maven: String
    var version: String
    var stable: Bool
}

func getFabricVersions(completion: @escaping ([FabricVersion]?) -> Void) {
    guard let url = URL(string: "https://meta.fabricmc.net/v2/versions/installer") else {
        completion(nil)
        return
    }
    
    let request = URLRequest(url: url)
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data, error == nil else {
            completion(nil)
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let versions = try decoder.decode([FabricVersion].self, from: data)
            
            completion(versions)
            
        } catch {
            completion(nil)
        }
    }.resume()
}
