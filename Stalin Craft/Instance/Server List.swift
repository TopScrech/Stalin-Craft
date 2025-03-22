import SwiftUI

struct ServerList: View {
    @EnvironmentObject private var instance: Instance
    
    var body: some View {
        VStack {
            List {
                
            }
        }
        .task {
            let url = instance.getGamePath()
            
            print(url)
            
            guard let path = findFilePath("servers.dat", in: url.path) else {
                return
            }
            
            readServersDat(at: path)
            //            print(servers)
        }
    }
}

struct Server {
    var name: String
    var ip: String
}

func readServersDat(at path: String) {
    guard let data = FileManager.default.contents(atPath: path) else {
        print("Failed to load file.")
        return
    }
    
    do {
        let nbtTags = try parseNBT(data: data)
        print(nbtTags)
    } catch NBTError.invalidFormat(let reason) {
        print("Parsing failed: \(reason)")
    } catch NBTError.unsupportedType(let type) {
        print("Unsupported NBT type: \(type)")
    } catch {
        print("An unexpected error occurred: \(error)")
    }
}

enum NBTTagType: UInt8 {
    case end = 0,
         byte = 1,
         short = 2,
         int = 3,
         long = 4,
         float = 5,
         double = 6,
         byteArray = 7,
         string = 8,
         list = 9,
         compound = 10,
         intArray = 11
}

struct NBTTag {
    var name: String
    var value: Any
}

func parseNBT(data: Data) throws -> [NBTTag] {
    var tags = [NBTTag]()
    let reader = BinaryDataReader(data: data)
    
    while reader.hasBytesAvailable() {
        let tagTypeByte = try reader.readByte()
        
        guard let tagType = NBTTagType(rawValue: tagTypeByte), tagType != .end else {
            break
        }
        
        let name = try reader.readString()
        let value = try readValue(ofType: tagType, with: reader)
        tags.append(NBTTag(name: name, value: value))
    }
    
    return tags
}

func readValue(ofType type: NBTTagType, with reader: BinaryDataReader) throws -> Any {
    switch type {
    case .byte:
        return try reader.readByte()
        
    case .int:
        return try reader.readInt()
        
    case .string:
        return try reader.readString()
        
    default:
        throw NBTError.unsupportedType(type: .byte)
    }
}

class BinaryDataReader {
    private var data: Data
    private var offset = 0
    
    init(data: Data) {
        self.data = data
    }
    
    func hasBytesAvailable() -> Bool {
        return offset < data.count
    }
    
    func readByte() throws -> UInt8 {
        guard offset < data.count else {
            throw NBTError.invalidFormat(reason: "No bytes available to read at offset \(offset).")
        }
        
        let value = data[offset]
        offset += 1
        
        return value
    }
    
    func readInt() throws -> Int {
        guard offset + 4 <= data.count else {
            print("Debug: Attempting to read Int at offset \(offset) with insufficient data left.")
            throw NBTError.invalidFormat(reason: "Insufficient data for Int at offset \(offset).")
        }
        
        let range = offset..<offset+4
        let value = data.subdata(in: range).withUnsafeBytes { $0.load(as: UInt32.self) }
        let interpretedValue = Int(UInt32(bigEndian: value))
        print("Debug: Read Int \(interpretedValue) at offset \(offset).")
        offset += 4
        
        return interpretedValue
    }
    
    func readString() throws -> String {
        let length = try readInt()
        
        guard length > 0, offset + length <= data.count else {
            throw NBTError.invalidFormat(reason: "String length \(length) out of bounds at offset \(offset).")
        }
        
        let range = offset..<offset+length
        offset += length
        
        guard let string = String(data: data.subdata(in: range), encoding: .utf8) else {
            throw NBTError.invalidFormat(reason: "Failed to decode string at offset \(offset-length).")
        }
        
        return string
    }
}

enum NBTError: Error {
    case invalidFormat(reason: String),
         unsupportedType(type: NBTTagType)
}
