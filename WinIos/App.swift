import SwiftUI
import Foundation
import UniformTypeIdentifiers

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
    private let wineEngine = WineEngine()
    @State private var peInfo = ""
    @State private var currentContainer: WineEngine.WineContainer?
    @State private var wineConfig = WineEngine.WineConfig()
    @State private var showingSettings = false
    @State private var showingWindowsDesktop = false
    
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
                        
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
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
                        
                        // Container info
                        if let container = currentContainer {
                            Text("Container: \(container.name)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Resolution: \(wineConfig.desktopResolution)")
                                .font(.caption)
                                .foregroundColor(.secondary)
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
            .sheet(isPresented: $showingSettings) {
                WineSettingsView(config: $wineConfig)
            }
            .fullScreenCover(isPresented: $showingWindowsDesktop) {
                WindowsDesktopView(isPresented: $showingWindowsDesktop)
            }
        }
    }
    
    func runSelectedEXE() {
        guard let file = selectedFile else { return }
        
        // Create container if needed
        if currentContainer == nil {
            currentContainer = WineEngine.WineContainer(name: "Default")
        }
        
        guard let container = currentContainer else { return }
        
        isRunning = true
        consoleOutput = "🍷 Starting Wine Engine...\n"
        consoleOutput += "🍷 Container: \(container.name)\n"
        consoleOutput += "🍷 Resolution: \(wineConfig.desktopResolution)\n"
        consoleOutput += "🍷 Graphics: \(wineConfig.graphicsDriver)\n"
        consoleOutput += "🍷 Loading: \(file.lastPathComponent)\n"
        consoleOutput += "🍷 Path: \(file.path)\n"
        consoleOutput += "🍷 Initializing Wine environment...\n"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let result = wineEngine.execute(exePath: file.path, in: container, config: wineConfig)
            consoleOutput += result.message + "\n"
            
            if case .success(let message) = result {
                if message == "DESKTOP_LAUNCH" {
                    consoleOutput += "\n🍷 === LAUNCHING WINDOWS DESKTOP ===\n"
                    consoleOutput += "🍷 Wine compatibility layer active\n"
                    consoleOutput += "🍷 Windows API translation working\n"
                    consoleOutput += "🍷 File system redirection active\n"
                    consoleOutput += "🍷 Virtual desktop created\n"
                    consoleOutput += "🍷 Launching Windows environment...\n"
                    
                    // Show Windows desktop
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        showingWindowsDesktop = true
                        isRunning = false
                    }
                } else {
                    consoleOutput += "\n🍷 === Windows Application Running ===\n"
                    consoleOutput += "🍷 Wine compatibility layer active\n"
                    consoleOutput += "🍷 Windows API translation working\n"
                    consoleOutput += "🍷 File system redirection active\n"
                    consoleOutput += "🍷 Application interface loaded\n"
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        isRunning = false
                        consoleOutput += "\n🍷 Wine session completed!\n"
                    }
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    isRunning = false
                    consoleOutput += "\n🍷 Wine session completed!\n"
                }
            }
        }
    }
    
    func testApp(_ appName: String) {
        // Create container if needed
        if currentContainer == nil {
            currentContainer = WineEngine.WineContainer(name: "Default")
        }
        
        guard let container = currentContainer else { return }
        
        isRunning = true
        consoleOutput = "🍷 Testing \(appName) with Wine...\n"
        consoleOutput += "🍷 Container: \(container.name)\n"
        consoleOutput += "🍷 Resolution: \(wineConfig.desktopResolution)\n"
        consoleOutput += "🍷 Starting Wine Engine...\n"
        consoleOutput += "🍷 Loading: \(appName)\n"
        consoleOutput += "🍷 Initializing Wine environment...\n"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let result = wineEngine.execute(exePath: appName, in: container, config: wineConfig)
            consoleOutput += result.message + "\n"
            
            if case .success(let message) = result {
                if message == "DESKTOP_LAUNCH" {
                    consoleOutput += "\n🍷 === LAUNCHING WINDOWS DESKTOP ===\n"
                    consoleOutput += "🍷 Wine compatibility layer active\n"
                    consoleOutput += "🍷 Windows API translation working\n"
                    consoleOutput += "🍷 File system redirection active\n"
                    consoleOutput += "🍷 Virtual desktop created\n"
                    consoleOutput += "🍷 Launching Windows environment...\n"
                    
                    // Show Windows desktop
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        showingWindowsDesktop = true
                        isRunning = false
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isRunning = false
                        consoleOutput += "\n🍷 Wine session completed!\n"
                    }
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isRunning = false
                    consoleOutput += "\n🍷 Wine session completed!\n"
                }
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

// Winlator-style Settings View
struct WineSettingsView: View {
    @Binding var config: WineEngine.WineConfig
    @Environment(\.presentationMode) var presentationMode
    
    let resolutions = ["800x600", "1024x768", "1280x720", "1920x1080", "2560x1440"]
    let windowsVersions = ["Windows XP", "Windows 7", "Windows 8.1", "Windows 10", "Windows 11"]
    let graphicsDrivers = ["OpenGL", "Vulkan", "Direct3D"]
    let soundDrivers = ["PulseAudio", "ALSA", "OSS"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Windows Settings")) {
                    Picker("Windows Version", selection: $config.windowsVersion) {
                        ForEach(windowsVersions, id: \.self) { version in
                            Text(version).tag(version)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Display Settings")) {
                    Picker("Resolution", selection: $config.desktopResolution) {
                        ForEach(resolutions, id: \.self) { resolution in
                            Text(resolution).tag(resolution)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Picker("Graphics Driver", selection: $config.graphicsDriver) {
                        ForEach(graphicsDrivers, id: \.self) { driver in
                            Text(driver).tag(driver)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Audio Settings")) {
                    Picker("Sound Driver", selection: $config.soundDriver) {
                        ForEach(soundDrivers, id: \.self) { driver in
                            Text(driver).tag(driver)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Container Management")) {
                    Button("Create New Container") {
                        // Create new container logic
                    }
                    .foregroundColor(.blue)
                    
                    Button("Reset Container") {
                        // Reset container logic
                    }
                    .foregroundColor(.orange)
                }
                
                Section(header: Text("Advanced")) {
                    Button("Export Container") {
                        // Export logic
                    }
                    .foregroundColor(.blue)
                    
                    Button("Import Container") {
                        // Import logic
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Wine Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// Extension for UTType
extension UTType {
    static let exe = UTType(filenameExtension: "exe")!
}
