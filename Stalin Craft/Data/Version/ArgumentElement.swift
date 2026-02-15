enum ArgumentElement: Codable, Equatable {
    case string(String),
         object(ConditionalArgument)
    
    init(from decoder: Decoder) throws {
        if let str = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(str)
        } else {
            let arg = try decoder.singleValueContainer().decode(ConditionalArgument.self)
            self = .object(arg)
        }
    }
    
    var actualValue: [String] {
        switch self {
        case .string(let value):
            [value]
            
        case .object(let obj):
            obj.value
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .string(let value):
            try container.encode(value)
            
        case .object(let value):
            try container.encode(value)
        }
    }
}
