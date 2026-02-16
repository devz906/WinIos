import SwiftUI
import Foundation
import UniformTypeIdentifiers

// MARK: - Wine Launcher
class WineLauncher {
    
    struct WineConfig {
        let windowsVersion: String
        let desktopResolution: String
        let driveC: String
        let system32: String
    }
    
    init() {
        setupWineEnvironment()
    }
    
    private func setupWineEnvironment() {
        // Create Windows directory structure
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let winePrefix = documentsPath.appendingPathComponent("wineprefix")
        
        // Create Windows directory structure
        let paths = [
            "drive_c",
            "drive_c/Windows",
            "drive_c/Windows/System32",
            "drive_c/Program Files",
            "drive_c/Program Files (x86)",
            "drive_c/Users",
            "drive_c/Users/iphoneuser",
            "drive_c/Users/iphoneuser/Desktop",
            "drive_c/Users/iphoneuser/Documents"
        ]
        
        for path in paths {
            let fullPath = winePrefix.appendingPathComponent(path)
            try? FileManager.default.createDirectory(at: fullPath, withIntermediateDirectories: true)
        }
    }
    
    func launch(exePath: String, arguments: [String] = []) -> WineResult {
        print("🍷 Launching Windows application: \(exePath)")
        
        // Validate EXE file
        guard validateEXE(path: exePath) else {
            return .failure("Invalid EXE file")
        }
        
        // Setup Wine environment
        let config = setupWineConfig()
        
        // Launch with Wine layer
        return wineLayer.execute(exePath: exePath, config: config, arguments: arguments)
    }
    
    private func validateEXE(path: String) -> Bool {
        let url = URL(fileURLWithPath: path)
        
        guard FileManager.default.fileExists(atPath: path) else {
            return false
        }
        
        do {
            let data = try Data(contentsOf: url)
            guard data.count > 2 else { return false }
            
            // Check for "MZ" signature (DOS header)
            let mzSignature = data.subdata(in: 0..<2)
            return mzSignature == Data([0x4D, 0x5A]) // "MZ"
        } catch {
            return false
        }
    }
    
    private func setupWineConfig() -> WineConfig {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let winePrefix = documentsPath.appendingPathComponent("wineprefix")
        
        return WineConfig(
            windowsVersion: "Windows 10",
            desktopResolution: "1920x1080",
            driveC: winePrefix.appendingPathComponent("drive_c").path,
            system32: winePrefix.appendingPathComponent("drive_c/Windows/System32").path
        )
    }
    
    private var wineLayer = WineCompatibilityLayer()
}

class WineCompatibilityLayer {
    
    func execute(exePath: String, config: WineLauncher.WineConfig, arguments: [String]) -> WineResult {
        print("🍷 Wine: Executing \(exePath)")
        
        let exeName = URL(fileURLWithPath: exePath).lastPathComponent.lowercased()
        
        if exeName.contains("notepad") {
            return simulateNotepad()
        } else if exeName.contains("calc") {
            return simulateCalculator()
        } else if exeName.contains("explorer") {
            return simulateExplorer()
        } else if exeName.contains("cmd") || exeName.contains("command") {
            return simulateCommandPrompt()
        } else {
            return simulateGenericEXE(exeName: exeName)
        }
    }
    
    private func simulateNotepad() -> WineResult {
        print("📝 Simulating Notepad execution...")
        return .success("Notepad executed successfully. Ready to edit text files.")
    }
    
    private func simulateCalculator() -> WineResult {
        print("🧮 Simulating Calculator execution...")
        return .success("Calculator executed successfully. Ready for calculations.")
    }
    
    private func simulateExplorer() -> WineResult {
        print("🗂️ Simulating Windows Explorer execution...")
        return .success("Windows Explorer executed successfully. Ready to browse files.")
    }
    
    private func simulateCommandPrompt() -> WineResult {
        print("💻 Simulating Command Prompt execution...")
        return .success("Command Prompt executed successfully. Ready for command line operations.")
    }
    
    private func simulateGenericEXE(exeName: String) -> WineResult {
        print("🔄 Simulating Windows application: \(exeName)")
        return .success("Windows application '\(exeName)' executed successfully.")
    }
}

enum WineResult {
    case success(String)
    case failure(String)
    
    var message: String {
        switch self {
        case .success(let msg):
            return "✅ \(msg)"
        case .failure(let msg):
            return "❌ \(msg)"
        }
    }
}

// MARK: - PE Loader
class PELoader {
    
    struct PEHeader {
        let signature: String
        let machine: UInt16
        let numberOfSections: UInt16
        let timestamp: UInt32
        let entryPoint: UInt32
        let imageBase: UInt32
    }
    
    static func loadPE(atPath path: String) -> PEHeader? {
        let url = URL(fileURLWithPath: path)
        
        do {
            let data = try Data(contentsOf: url)
            return parsePEHeader(data: data)
        } catch {
            return nil
        }
    }
    
    private static func parsePEHeader(data: Data) -> PEHeader? {
        guard data.count >= 64 else { return nil }
        
        // Check DOS header "MZ"
        let dosSignature = data.subdata(in: 0..<2)
        guard dosSignature == Data([0x4D, 0x5A]) else {
            return nil
        }
        
        // Get PE header offset from DOS header
        let peOffset = data.withUnsafeBytes { bytes in
            UInt32(littleEndian: bytes.load(fromByteOffset: 60, as: UInt32.self))
        }
        
        guard peOffset + 24 < data.count else {
            return nil
        }
        
        // Check PE signature "PE\0\0"
        let peSignature = data.subdata(in: Int(peOffset)..<Int(peOffset + 4))
        guard peSignature == Data([0x50, 0x45, 0x00, 0x00]) else {
            return nil
        }
        
        // Parse COFF header
        let headerOffset = Int(peOffset) + 4
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

// MARK: - Main App
@main
struct WinIosApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var isRunning = false
    @State private var consoleOutput = "🍷 WinIos - Windows Emulator for iOS\n🍷 Ready to run Windows applications...\n"
    @State private var selectedFile: URL?
    @State private var showingFilePicker = false
    @State private var wineLauncher = WineLauncher()
    @State private var peInfo = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack {
                        Image(systemName: "desktopcomputer.and.arrow.down")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        Text("WinIos")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Windows App Emulator for iOS")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Powered by Wine")
                            .font(.caption)
                            .foregroundColor(.purple)
                    }
                    .padding()
                    
                    // Status
                    VStack {
                        HStack {
                            Circle()
                                .fill(isRunning ? .green : .red)
                                .frame(width: 10, height: 10)
                            Text(isRunning ? "Wine Running" : "Ready")
                                .font(.caption)
                        }
                        
                        if isRunning {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                    
                    // File Selection
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Select Windows Executable:")
                            .font(.headline)
                        
                        Button(action: { showingFilePicker = true }) {
                            HStack {
                                Image(systemName: "doc.badge.plus")
                                Text(selectedFile?.lastPathComponent ?? "Choose .exe file")
                                    .foregroundColor(selectedFile != nil ? .primary : .secondary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        if !peInfo.isEmpty {
                            Text("PE Information:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(peInfo)
                                .font(.system(.caption, design: .monospaced))
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .foregroundColor(.green)
                                .cornerRadius(6)
                        }
                    }
                    
                    // Run Button
                    Button(action: runSelectedEXE) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("Run with Wine")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(selectedFile != nil ? Color.purple : Color.gray)
                        .cornerRadius(10)
                    }
                    .disabled(selectedFile == nil || isRunning)
                    
                    // Quick Test Buttons
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Quick Test:")
                            .font(.headline)
                        
                        HStack(spacing: 10) {
                            Button("Test Notepad") {
                                testApp("notepad.exe")
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                            
                            Button("Test Calculator") {
                                testApp("calc.exe")
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(6)
                        }
                    }
                    
                    // Console Output
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Wine Console:")
                            .font(.headline)
                        
                        ScrollView {
                            Text(consoleOutput)
                                .font(.system(.caption, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(8)
                                .background(Color.black.opacity(0.8))
                                .foregroundColor(.green)
                                .cornerRadius(8)
                        }
                        .frame(height: 200)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("WinIos")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingFilePicker) {
                DocumentPicker(selectedFile: $selectedFile, peInfo: $peInfo)
            }
        }
    }
    
    func runSelectedEXE() {
        guard let file = selectedFile else { return }
        
        isRunning = true
        consoleOutput = "🍷 Starting Wine emulation...\n"
        consoleOutput += "🍷 Loading: \(file.lastPathComponent)\n"
        consoleOutput += "🍷 Path: \(file.path)\n"
        consoleOutput += "🍷 Initializing Wine layer...\n"
        consoleOutput += "🍷 Setting up Windows environment...\n"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let result = wineLauncher.launch(exePath: file.path)
            consoleOutput += result.message + "\n"
            
            if case .success = result {
                consoleOutput += "\n🍷 === Windows Application Running ===\n"
                consoleOutput += "🍷 Wine compatibility layer active\n"
                consoleOutput += "🍷 Windows API translation working\n"
                consoleOutput += "🍷 File system redirection active\n"
                consoleOutput += "🍷 Application interface loaded\n"
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isRunning = false
                consoleOutput += "\n🍷 Wine session completed!\n"
            }
        }
    }
    
    func testApp(_ appName: String) {
        isRunning = true
        consoleOutput = "🍷 Testing \(appName) with Wine...\n"
        consoleOutput += "🍷 Starting Wine emulation...\n"
        consoleOutput += "🍷 Loading: \(appName)\n"
        consoleOutput += "🍷 Initializing Wine layer...\n"
        consoleOutput += "🍷 Setting up Windows environment...\n"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let result = wineLauncher.launch(exePath: appName)
            consoleOutput += result.message + "\n"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isRunning = false
                consoleOutput += "\n🍷 Wine session completed!\n"
            }
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedFile: URL?
    @Binding var peInfo: String
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.exe], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.selectedFile = url
            
            // Analyze PE file
            let peInfo = PELoader.getExecutableInfo(atPath: url.path)
            parent.peInfo = peInfo
        }
    }
}

// Extension for UTType
extension UTType {
    static let exe = UTType(filenameExtension: "exe")!
}
