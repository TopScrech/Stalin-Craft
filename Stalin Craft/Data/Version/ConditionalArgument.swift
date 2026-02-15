struct ConditionalArgument: Codable, Equatable {
    let rules: [Rule]
    let value: [String]
    
    enum CodingKeys: String, CodingKey {
        case rules,
             value
    }
    
    init(rules: [Rule], value: [String]) {
        self.rules = rules
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        rules = try container.decode([Rule].self, forKey: .rules)
        
        if let singleValue = try? container.decode(String.self, forKey: .value) {
            value = [singleValue]
        } else {
            value = try container.decode([String].self, forKey: .value)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(rules, forKey: .rules)
        try container.encode(value, forKey: .value)
    }
}
