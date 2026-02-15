import Foundation

final class InstancePreferences: ObservableObject, Codable {
    @Published var runtime = RuntimePreferences().invalidate()
}
