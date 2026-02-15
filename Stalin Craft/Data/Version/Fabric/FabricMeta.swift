import Foundation

struct FabricMeta {
    static func `get`(path: String) -> Http.RequestBuilder {
        Http.get("https://meta.fabricmc.net/\(path)")
    }
    
    static func requestFabricLoaderVersions() -> Http.RequestBuilder {
        Self.get(path: "/v2/versions/loader")
    }
    
    static func requestProfile(gameVersion: String, loaderVersion: String) -> Http.RequestBuilder {
        Self.get(path: "/v2/versions/loader/\(gameVersion)/\(loaderVersion)/profile/json")
    }
    
    static func getFabricLoaderVersions() async throws -> [FabricLoaderVersion] {
        do {
            let (data, response) = try await Self.requestFabricLoaderVersions().request()
            
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                logger.error("Received invalid status code from fabric meta while fetching profile")
                
                throw FabricMetaError.loaderVersionsInvalidResponse
            }
            
            do {
                return try JSONDecoder().decode([FabricLoaderVersion].self, from: data)
            } catch {
                logger.error("Received malformed response from fabric meta while fetching profile", error)
                
                throw FabricMetaError.loaderVersionsInvalidResponse
            }
            
        } catch let err as FabricMetaError {
            throw err
            
        } catch {
            throw FabricMetaError.loaderVersionsCouldNotConnect
        }
    }
    
    static func getProfile(gameVersion: String, loaderVersion: String) async throws -> Version {
        do {
            let (data, response) = try await Self.requestProfile(gameVersion: gameVersion, loaderVersion: loaderVersion).request()
            
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                logger.error("Received invalid status code from fabric meta while fetching profile")
                throw FabricMetaError.profileInvalidResponse
            }
            
            do {
                print(String(data: data, encoding: .utf8)!)
                
                return try JSONDecoder().decode(Version.self, from: data)
            } catch {
                logger.error("Received malformed response from fabric meta while fetching profile", error)
                
                throw FabricMetaError.profileInvalidResponse
            }
            
        } catch let err as FabricMetaError {
            throw err
            
        } catch {
            throw FabricMetaError.profileCouldNotConnect
        }
    }
    
    enum FabricMetaError: Error {
        case loaderVersionsInvalidResponse,
             loaderVersionsCouldNotConnect,
             profileInvalidResponse,
             profileCouldNotConnect
    }
}
