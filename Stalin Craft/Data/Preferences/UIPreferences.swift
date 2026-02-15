import Foundation

final class UiPreferences: Codable, ObservableObject {
    @Published var compactList = false
    @Published var compactInstanceLogo = false
}
