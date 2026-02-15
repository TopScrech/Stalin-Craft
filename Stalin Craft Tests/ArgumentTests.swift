//import XCTest
//import InnateKit
//
//class ArgumentTests: XCTestCase {
//    func test() throws {
//        let toReplace = "${auth_player_name} ${auth_session} --gameDir ${game_directory} --assetsDir ${game_assets}"
//        
//        let argumentProvider = ArgumentProvider()
//        argumentProvider.username("Test")
//        argumentProvider.accessToken("12345")
//        argumentProvider.gameDir(URL(string: "/usr/local/Cellar")!)
//        argumentProvider.assetsDir(URL(string: "/opt/homebrew")!)
//        
//        let replaced = argumentProvider.accept(toReplace)
//        
//        XCTAssertEqual(replaced, "Test 12345 --gameDir /usr/local/Cellar --assetsDir /opt/homebrew")
//    }
//}
