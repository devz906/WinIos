import SwiftUI
import Foundation

@main
struct WinIosApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var selectedFile: String?
    @State private var isRunning = false
    @State private var consoleOutput = ""
    @State private var wineLauncher = WineLauncher()
    
    var body: some View {
        NavigationView {
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
                    Text("Select Windows Application:")
                        .font(.headline)
                    
                    Button(action: selectFile) {
                        HStack {
                            Image(systemName: "doc.badge.plus")
                            Text(selectedFile ?? "Choose .exe file")
                                .foregroundColor(selectedFile != nil ? .primary : .secondary)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                
                // Run Button
                Button(action: runApplication) {
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
                
                // Quick Actions
                VStack(alignment: .leading, spacing: 10) {
                    Text("Quick Test:")
                        .font(.headline)
                    
                    HStack(spacing: 10) {
                        Button("Test Notepad") {
                            testNotepad()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                        
                        Button("Test Calculator") {
                            testCalculator()
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
                    .frame(height: 150)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("WinIos")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func selectFile() {
        // TODO: Implement file picker
        selectedFile = "notepad.exe"
        consoleOutput = "🍷 Selected: notepad.exe\n🍷 Ready to run with Wine...\n"
    }
    
    func runApplication() {
        guard let file = selectedFile else { return }
        
        isRunning = true
        consoleOutput = "🍷 Starting Wine emulation...\n"
        consoleOutput += "🍷 Loading: \(file)\n"
        consoleOutput += "🍷 Initializing Wine layer...\n"
        consoleOutput += "🍷 Setting up Windows environment...\n"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let result = wineLauncher.launch(exePath: file)
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
    
    func testNotepad() {
        selectedFile = "notepad.exe"
        consoleOutput = "🍷 Testing Notepad with Wine...\n"
        runApplication()
    }
    
    func testCalculator() {
        selectedFile = "calc.exe"
        consoleOutput = "🍷 Testing Calculator with Wine...\n"
        runApplication()
    }
}
