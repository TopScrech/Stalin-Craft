import SwiftUI

struct SelectedInstanceKey: FocusedValueKey {
    typealias Value = Instance
}

extension FocusedValues {
    var selectedInstance: SelectedInstanceKey.Value? {
        get {
            self[SelectedInstanceKey.self]
        }
        
        set {
            self[SelectedInstanceKey.self] = newValue
        }
    }
}
