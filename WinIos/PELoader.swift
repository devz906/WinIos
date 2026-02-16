import Foundation

// PE (Portable Executable) loader for Windows EXE files
class PELoader {
    
    struct PEHeader {
        let signature: String
        let machine: UInt16
        let numberOfSections: UInt16
        let timestamp: UInt32
        let entryPoint: UInt32
        let imageBase: UInt32
    }
    
    // Load and validate Windows PE executable
    static func loadPE(atPath path: String) -> PEHeader? {
        let url = URL(fileURLWithPath: path)
        
        do {
            let data = try Data(contentsOf: url)
            return parsePEHeader(data: data)
        } catch {
            print("❌ Failed to load PE file: \(error)")
            return nil
        }
    }
    
    private static func parsePEHeader(data: Data) -> PEHeader? {
        guard data.count >= 64 else { return nil }
        
        // Check DOS header "MZ"
        let dosSignature = data.subdata(in: 0..<2)
        guard dosSignature == Data([0x4D, 0x5A]) else {
            print("❌ Invalid DOS signature")
            return nil
        }
        
        // Get PE header offset from DOS header
        let peOffset = data.withUnsafeBytes { bytes in
            UInt32(littleEndian: bytes.load(fromByteOffset: 60, as: UInt32.self))
        }
        
        guard peOffset + 24 < data.count else {
            print("❌ PE header offset out of bounds")
            return nil
        }
        
        // Check PE signature "PE\0\0"
        let peSignature = data.subdata(in: Int(peOffset)..<Int(peOffset + 4))
        guard peSignature == Data([0x50, 0x45, 0x00, 0x00]) else {
            print("❌ Invalid PE signature")
            return nil
        }
        
        // Parse COFF header
        let headerOffset = peOffset + 4
        return data.withUnsafeBytes { bytes in
            PEHeader(
                signature: "PE\0\0",
                machine: UInt16(littleEndian: bytes.load(fromByteOffset: headerOffset, as: UInt16.self)),
                numberOfSections: UInt16(littleEndian: bytes.load(fromByteOffset: headerOffset + 2, as: UInt16.self)),
                timestamp: UInt32(littleEndian: bytes.load(fromByteOffset: headerOffset + 4, as: UInt32.self)),
                entryPoint: UInt32(littleEndian: bytes.load(fromByteOffset: headerOffset + 16, as: UInt32.self)),
                imageBase: UInt32(littleEndian: bytes.load(fromByteOffset: headerOffset + 28, as: UInt32.self))
            )
        }
    }
    
    // Get executable information
    static func getExecutableInfo(atPath path: String) -> String {
        guard let peHeader = loadPE(atPath: path) else {
            return "Failed to load PE file"
        }
        
        var info = "📁 PE File Information:\n"
        info += "   Signature: \(peHeader.signature)\n"
        info += "   Machine: 0x\(String(peHeader.machine, radix: 16))\n"
        info += "   Sections: \(peHeader.numberOfSections)\n"
        info += "   Entry Point: 0x\(String(peHeader.entryPoint, radix: 16))\n"
        info += "   Image Base: 0x\(String(peHeader.imageBase, radix: 16))\n"
        
        // Machine type interpretation
        switch peHeader.machine {
        case 0x014c:
            info += "   Architecture: i386 (32-bit)\n"
        case 0x8664:
            info += "   Architecture: x64 (64-bit)\n"
        default:
            info += "   Architecture: Unknown (0x\(String(peHeader.machine, radix: 16)))\n"
        }
        
        return info
    }
}
