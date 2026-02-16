import SwiftUI
import Foundation

// Real Windows Desktop Environment like Winlator
struct WindowsDesktopView: View {
    @State private var runningApps: [WindowsApp] = []
    @State private var showDesktop = true
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // Desktop background
            LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Desktop icons
            if showDesktop {
                VStack {
                    HStack {
                        DesktopIcon(icon: "computer", title: "My Computer") {
                            openExplorer()
                        }
                        Spacer()
                        DesktopIcon(icon: "doc.text", title: "Documents") {
                            openDocuments()
                        }
                        Spacer()
                        DesktopIcon(icon: "gear", title: "Settings") {
                            // Open settings
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    HStack {
                        DesktopIcon(icon: "play.rectangle", title: "Notepad") {
                            openNotepad()
                        }
                        Spacer()
                        DesktopIcon(icon: "plusminus.rectangle", title: "Calculator") {
                            openCalculator()
                        }
                        Spacer()
                        DesktopIcon(icon: "terminal", title: "Command Prompt") {
                            openCMD()
                        }
                    }
                    .padding()
                }
            }
            
            // Running app windows
            ForEach(runningApps) { app in
                AppWindow(app: app, onClose: {
                    runningApps.removeAll { $0.id == app.id }
                })
            }
            
            // Taskbar
            VStack {
                Spacer()
                HStack {
                    // Start button
                    Button(action: { 
                        showDesktop.toggle()
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("Start")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.8))
                        .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                    // Running apps on taskbar
                    ForEach(runningApps) { app in
                        Button(action: {
                            // Bring app to front
                        }) {
                            Image(systemName: app.icon)
                                .padding(8)
                                .background(runningApps.first?.id == app.id ? Color.gray.opacity(0.5) : Color.clear)
                                .cornerRadius(4)
                        }
                    }
                    
                    Spacer()
                    
                    // System tray
                    HStack(spacing: 8) {
                        Image(systemName: "wifi")
                        Image(systemName: "battery.100")
                        Text("12:34 PM")
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Color.gray.opacity(0.9))
            }
        }
        .navigationBarHidden(true)
    }
    
    private func openNotepad() {
        let notepadApp = WindowsApp(
            id: UUID(),
            name: "Notepad",
            icon: "doc.text",
            content: AnyView(NotepadView()),
            position: CGPoint(x: 100, y: 100),
            size: CGSize(width: 600, height: 400)
        )
        runningApps.append(notepadApp)
    }
    
    private func openCalculator() {
        let calcApp = WindowsApp(
            id: UUID(),
            name: "Calculator",
            icon: "plusminus.rectangle",
            content: AnyView(CalculatorView()),
            position: CGPoint(x: 200, y: 150),
            size: CGSize(width: 320, height: 480)
        )
        runningApps.append(calcApp)
    }
    
    private func openCMD() {
        let cmdApp = WindowsApp(
            id: UUID(),
            name: "Command Prompt",
            icon: "terminal",
            content: AnyView(CommandPromptView()),
            position: CGPoint(x: 150, y: 200),
            size: CGSize(width: 700, height: 400)
        )
        runningApps.append(cmdApp)
    }
    
    private func openExplorer() {
        let explorerApp = WindowsApp(
            id: UUID(),
            name: "Windows Explorer",
            icon: "computer",
            content: AnyView(ExplorerView()),
            position: CGPoint(x: 50, y: 50),
            size: CGSize(width: 800, height: 600)
        )
        runningApps.append(explorerApp)
    }
    
    private func openDocuments() {
        let explorerApp = WindowsApp(
            id: UUID(),
            name: "Documents",
            icon: "doc.text",
            content: AnyView(ExplorerView(initialPath: "C:\\Users\\iphoneuser\\Documents")),
            position: CGPoint(x: 100, y: 100),
            size: CGSize(width: 800, height: 600)
        )
        runningApps.append(explorerApp)
    }
}

// Desktop icon component
struct DesktopIcon: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(8)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// App window component
struct AppWindow: View {
    let app: WindowsApp
    let onClose: () -> Void
    @State private var position: CGPoint
    @State private var size: CGSize
    @State private var isMaximized = false
    
    init(app: WindowsApp, onClose: @escaping () -> Void) {
        self.app = app
        self.onClose = onClose
        self._position = State(initialValue: app.position)
        self._size = State(initialValue: app.size)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                Image(systemName: app.icon)
                    .foregroundColor(.primary)
                
                Text(app.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: { isMaximized.toggle() }) {
                        Image(systemName: isMaximized ? "minus.rectangle" : "plus.rectangle")
                            .frame(width: 16, height: 16)
                    }
                    
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .frame(width: 16, height: 16)
                    }
                }
                .foregroundColor(.primary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.gray.opacity(0.8))
            
            // App content
            app.content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
        }
        .frame(width: size.width, height: size.height)
        .background(Color.gray.opacity(0.9))
        .cornerRadius(8)
        .shadow(radius: 10)
        .position(position)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !isMaximized {
                        position.x += value.translation.x
                        position.y += value.translation.y
                    }
                }
        )
    }
}

// Windows app model
struct WindowsApp: Identifiable {
    let id: UUID
    let name: String
    let icon: String
    let content: AnyView
    let position: CGPoint
    let size: CGSize
}

// Notepad view
struct NotepadView: View {
    @State private var text = ""
    @State private var fileName = "Untitled"
    
    var body: some View {
        VStack(spacing: 0) {
            // Menu bar
            HStack {
                Menu("File") {
                    Button("New") { text = ""; fileName = "Untitled" }
                    Button("Open") { /* Open file */ }
                    Button("Save") { /* Save file */ }
                    Button("Save As") { /* Save as */ }
                }
                
                Menu("Edit") {
                    Button("Undo") { /* Undo */ }
                    Button("Redo") { /* Redo */ }
                    Button("Cut") { /* Cut */ }
                    Button("Copy") { /* Copy */ }
                    Button("Paste") { /* Paste */ }
                }
                
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Color.gray.opacity(0.3))
            
            // Text area
            TextEditor(text: $text)
                .font(.system(.body, design: .monospaced))
                .padding(4)
        }
    }
}

// Calculator view
struct CalculatorView: View {
    @State private var display = "0"
    @State private var currentNumber = 0.0
    @State private var previousNumber = 0.0
    @State private var operation = ""
    @State private var isNewNumber = true
    
    let buttons = [
        ["C", "±", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "−"],
        ["1", "2", "3", "+"],
        ["0", ".", "", "="]
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Display
            Text(display)
                .font(.system(size: 32, weight: .regular, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
            
            // Buttons
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(row, id: \.self) { button in
                        Button(action: {
                            handleButton(button)
                        }) {
                            Text(button)
                                .font(.title2)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(buttonColor(for: button))
                                .foregroundColor(button == "=" ? .white : .primary)
                        }
                    }
                }
                .frame(height: 60)
            }
        }
    }
    
    private func buttonColor(for button: String) -> Color {
        if button == "C" || button == "±" || button == "%" {
            return Color.gray.opacity(0.3)
        } else if button == "÷" || button == "×" || button == "−" || button == "+" {
            return Color.orange.opacity(0.7)
        } else if button == "=" {
            return Color.blue
        } else {
            return Color.gray.opacity(0.1)
        }
    }
    
    private func handleButton(_ button: String) {
        switch button {
        case "C":
            display = "0"
            currentNumber = 0
            previousNumber = 0
            operation = ""
            isNewNumber = true
        case "±":
            currentNumber = -currentNumber
            display = String(currentNumber)
        case "%":
            currentNumber = currentNumber / 100
            display = String(currentNumber)
        case "÷", "×", "−", "+":
            operation = button
            previousNumber = currentNumber
            isNewNumber = true
        case "=":
            if !operation.isEmpty {
                switch operation {
                case "÷":
                    currentNumber = previousNumber / currentNumber
                case "×":
                    currentNumber = previousNumber * currentNumber
                case "−":
                    currentNumber = previousNumber - currentNumber
                case "+":
                    currentNumber = previousNumber + currentNumber
                default:
                    break
                }
                display = String(currentNumber)
                operation = ""
                isNewNumber = true
            }
        default:
            if isNewNumber {
                display = button
                currentNumber = Double(button) ?? 0
                isNewNumber = false
            } else {
                display += button
                currentNumber = Double(display) ?? 0
            }
        }
    }
}

// Command Prompt view
struct CommandPromptView: View {
    @State private var commands: [String] = []
    @State private var currentCommand = ""
    @State private var output = [
        "Microsoft Windows [Version 10.0.19045.2364]",
        "(c) Microsoft Corporation. All rights reserved.",
        "",
        "C:\\Users\\iphoneuser>"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Output area
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(output, id: \.self) { line in
                        Text(line)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.black)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
            }
            
            // Input area
            HStack {
                Text("C:\\Users\\iphoneuser>")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.black)
                
                TextField("", text: $currentCommand)
                    .font(.system(.body, design: .monospaced))
                    .textFieldStyle(PlainTextFieldStyle())
                    .onSubmit {
                        executeCommand()
                    }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.gray.opacity(0.1))
        }
    }
    
    private func executeCommand() {
        let command = currentCommand.trimmingCharacters(in: .whitespacesAndNewlines)
        output.append("C:\\Users\\iphoneuser> \(command)")
        
        switch command.lowercased() {
        case "help":
            output.append("Available commands:")
            output.append("  help     - Show this help message")
            output.append("  dir      - List directory contents")
            output.append("  echo     - Display message")
            output.append("  exit     - Exit command prompt")
            output.append("  ver      - Show Windows version")
        case "dir":
            output.append(" Volume in drive C is Windows")
            output.append(" Directory of C:\\Users\\iphoneuser")
            output.append("")
            output.append("2024-01-15  12:34    <DIR>     Desktop")
            output.append("2024-01-15  12:34    <DIR>     Documents")
            output.append("2024-01-15  12:34    <DIR>     Downloads")
            output.append("2024-01-15  12:34           1024 test.txt")
            output.append("               1 File(s)      1024 bytes")
        case "ver":
            output.append("Microsoft Windows [Version 10.0.19045.2364]")
        case let cmd where cmd.hasPrefix("echo "):
            let message = String(cmd.dropFirst(5))
            output.append(message)
        case "exit":
            // Close window
            break
        default:
            output.append("'\(command)' is not recognized as an internal or external command,")
            output.append("operable program or batch file.")
        }
        
        output.append("C:\\Users\\iphoneuser>")
        currentCommand = ""
    }
}

// Windows Explorer view
struct ExplorerView: View {
    @State private var selectedPath: String
    @State private var files: [FileItem] = []
    
    init(initialPath: String = "C:\\") {
        self._selectedPath = State(initialValue: initialPath)
        self._files = State(initialValue: generateFiles(for: initialPath))
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(alignment: .leading, spacing: 0) {
                Text("Quick access")
                    .font(.headline)
                    .padding()
                
                SidebarItem(icon: "desktopcomputer", title: "Desktop", path: "C:\\Users\\iphoneuser\\Desktop")
                SidebarItem(icon: "doc.text", title: "Documents", path: "C:\\Users\\iphoneuser\\Documents")
                SidebarItem(icon: "photo", title: "Pictures", path: "C:\\Users\\iphoneuser\\Pictures")
                SidebarItem(icon: "music.note", title: "Music", path: "C:\\Users\\iphoneuser\\Music")
                SidebarItem(icon: "tv", title: "Videos", path: "C:\\Users\\iphoneuser\\Videos")
                
                Spacer()
            }
            .frame(width: 200)
            .background(Color.gray.opacity(0.1))
            
            // Main content
            VStack(spacing: 0) {
                // Address bar
                HStack {
                    Image(systemName: "arrow.left")
                    Image(systemName: "arrow.right")
                    Image(systemName: "arrow.up")
                    
                    TextField("", text: $selectedPath)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Spacer()
                    
                    Image(systemName: "magnifyingglass")
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                
                // File list
                List(files) { file in
                    HStack {
                        Image(systemName: file.icon)
                            .foregroundColor(file.isDirectory ? .blue : .gray)
                        
                        VStack(alignment: .leading) {
                            Text(file.name)
                                .font(.headline)
                            if !file.isDirectory {
                                Text("\(file.size) bytes")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if !file.isDirectory {
                            Text(file.modifiedDate)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if file.isDirectory {
                            selectedPath = file.path
                            files = generateFiles(for: file.path)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
}

struct SidebarItem: View {
    let icon: String
    let title: String
    let path: String
    @Binding var selectedPath: String
    
    init(icon: String, title: String, path: String) {
        self.icon = icon
        self.title = title
        self.path = path
        self._selectedPath = State(initialValue: "")
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(selectedPath == path ? Color.blue.opacity(0.2) : Color.clear)
        .onTapGesture {
            selectedPath = path
        }
    }
}

struct FileItem: Identifiable {
    let id = UUID()
    let name: String
    let isDirectory: Bool
    let size: String
    let modifiedDate: String
    let path: String
    let icon: String
}

func generateFiles(for path: String) -> [FileItem] {
    switch path {
    case "C:\\":
        return [
            FileItem(name: "Program Files", isDirectory: true, size: "", modifiedDate: "", path: "C:\\Program Files", icon: "folder"),
            FileItem(name: "Program Files (x86)", isDirectory: true, size: "", modifiedDate: "", path: "C:\\Program Files (x86)", icon: "folder"),
            FileItem(name: "Users", isDirectory: true, size: "", modifiedDate: "", path: "C:\\Users", icon: "folder"),
            FileItem(name: "Windows", isDirectory: true, size: "", modifiedDate: "", path: "C:\\Windows", icon: "folder"),
            FileItem(name: "autoexec.bat", isDirectory: false, size: "1024", modifiedDate: "2024-01-15", path: "C:\\autoexec.bat", icon: "doc.text"),
        ]
    case "C:\\Users\\iphoneuser\\Documents":
        return [
            FileItem(name: "README.txt", isDirectory: false, size: "2048", modifiedDate: "2024-01-15", path: "C:\\Users\\iphoneuser\\Documents\\README.txt", icon: "doc.text"),
            FileItem(name: "Work", isDirectory: true, size: "", modifiedDate: "", path: "C:\\Users\\iphoneuser\\Documents\\Work", icon: "folder"),
            FileItem(name: "Personal", isDirectory: true, size: "", modifiedDate: "", path: "C:\\Users\\iphoneuser\\Documents\\Personal", icon: "folder"),
        ]
    default:
        return [
            FileItem(name: "File1.txt", isDirectory: false, size: "1024", modifiedDate: "2024-01-15", path: "\(path)\\File1.txt", icon: "doc.text"),
            FileItem(name: "File2.txt", isDirectory: false, size: "2048", modifiedDate: "2024-01-14", path: "\(path)\\File2.txt", icon: "doc.text"),
        ]
    }
}
