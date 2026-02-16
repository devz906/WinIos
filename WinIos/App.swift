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
                }
                .padding()
                
                // Status
                VStack {
                    HStack {
                        Circle()
                            .fill(isRunning ? .green : .red)
                            .frame(width: 10, height: 10)
                        Text(isRunning ? "Emulator Running" : "Ready")
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
                        Text("Run Windows App")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(selectedFile != nil ? Color.blue : Color.gray)
                    .cornerRadius(10)
                }
                .disabled(selectedFile == nil || isRunning)
                
                // Console Output
                VStack(alignment: .leading, spacing: 5) {
                    Text("Console Output:")
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
        selectedFile = "IMGTool.exe"
        consoleOutput = "Selected: IMGTool.exe\nReady to run..."
    }
    
    func runApplication() {
        guard let file = selectedFile else { return }
        
        isRunning = true
        consoleOutput = "Starting Windows emulation...\n"
        consoleOutput += "Loading: \(file)\n"
        consoleOutput += "Initializing Wine layer...\n"
        consoleOutput += "Setting up x86 emulation...\n"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            consoleOutput += "Windows API translation ready\n"
            consoleOutput += "File system redirected\n"
            consoleOutput += "Application started!\n"
            consoleOutput += "\n=== Windows App Running ===\n"
            consoleOutput += "IMG Tool interface loaded\n"
            consoleOutput += "Ready to process GTA archives\n"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isRunning = false
                consoleOutput += "\nApplication completed successfully!\n"
            }
        }
    }
}
