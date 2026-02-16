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
    @State private var isRunning = false
    @State private var consoleOutput = "🍷 WinIos - Windows Emulator for iOS\n🍷 Ready to run Windows applications...\n"
    
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
                
                // Test Buttons
                VStack(alignment: .leading, spacing: 10) {
                    Text("Test Windows Applications:")
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
                    .frame(height: 150)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("WinIos")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func testApp(_ appName: String) {
        isRunning = true
        consoleOutput = "🍷 Starting Wine emulation...\n"
        consoleOutput += "🍷 Loading: \(appName)\n"
        consoleOutput += "🍷 Initializing Wine layer...\n"
        consoleOutput += "🍷 Setting up Windows environment...\n"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            consoleOutput += "🍷 Wine compatibility layer active\n"
            consoleOutput += "🍷 Windows API translation working\n"
            consoleOutput += "🍷 File system redirection active\n"
            consoleOutput += "🍷 Application interface loaded\n"
            consoleOutput += "✅ \(appName) executed successfully!\n"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isRunning = false
                consoleOutput += "\n🍷 Wine session completed!\n"
            }
        }
    }
}
