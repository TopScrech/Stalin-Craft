struct InstanceLogo: Codable {
    var logoType: LogoType
    var string: String
    
    enum LogoType: String, Codable {
        case symbol,
             file,
             builtin
    }
}
