/*
 * QuoteSaver - Configuration panel for quote file selection
 * 
 * Authors: Claude (Anthropic) & flare576
 * License: Open Source
 */

import Cocoa
import ScreenSaver

class ConfigureSheet: NSWindowController {
    private var filePathTextField: NSTextField!
    private var browseButton: NSButton!
    private var okButton: NSButton!
    private var cancelButton: NSButton!
    private var quoteFilePath: String = ""
    
    override init(window: NSWindow?) {
        super.init(window: window)
        createWindow()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createWindow()
    }
    
    convenience init() {
        self.init(window: nil)
    }
    
    override func loadWindow() {
        createWindow()
    }
    
    private func createWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Quote Saver Options"
        window.center()
        
        let contentView = NSView(frame: window.contentView!.bounds)
        window.contentView = contentView
        
        // Label
        let label = NSTextField(labelWithString: "Quote File Path:")
        label.frame = NSRect(x: 20, y: 150, width: 120, height: 17)
        label.isEditable = false
        label.isBordered = false
        label.backgroundColor = NSColor.clear
        contentView.addSubview(label)
        
        // Text field (made wider and positioned to not wrap)
        filePathTextField = NSTextField(frame: NSRect(x: 20, y: 110, width: 380, height: 22))
        filePathTextField.target = self
        filePathTextField.action = #selector(filePathChanged(_:))
        contentView.addSubview(filePathTextField)
        
        // Browse button (positioned below text field)
        browseButton = NSButton(frame: NSRect(x: 410, y: 105, width: 70, height: 32))
        browseButton.title = "Browse..."
        browseButton.bezelStyle = .rounded
        browseButton.target = self
        browseButton.action = #selector(browseForFile(_:))
        contentView.addSubview(browseButton)
        
        // OK button
        okButton = NSButton(frame: NSRect(x: 330, y: 20, width: 70, height: 32))
        okButton.title = "OK"
        okButton.bezelStyle = .rounded
        okButton.target = self
        okButton.action = #selector(ok(_:))
        contentView.addSubview(okButton)
        
        // Cancel button
        cancelButton = NSButton(frame: NSRect(x: 410, y: 20, width: 70, height: 32))
        cancelButton.title = "Cancel"
        cancelButton.bezelStyle = .rounded
        cancelButton.target = self
        cancelButton.action = #selector(cancel(_:))
        contentView.addSubview(cancelButton)
        
        self.window = window
        loadCurrentSettings()
    }
    
    private func loadCurrentSettings() {
        let defaults = ScreenSaverDefaults(forModuleWithName: "QuoteSaver")
        quoteFilePath = defaults?.string(forKey: "QuoteFilePath") ?? getDefaultQuoteFilePath()
        filePathTextField?.stringValue = quoteFilePath
    }
    
    private func getDefaultQuoteFilePath() -> String {
        // First try the user's Desktop
        let desktopPath = NSHomeDirectory() + "/Desktop/codeQuotes.txt"
        if FileManager.default.fileExists(atPath: desktopPath) {
            return desktopPath
        }
        
        // Then try a ~/.config location
        let configDir = NSHomeDirectory() + "/.config"
        let configPath = configDir + "/quotes.txt"
        
        // Create .config directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: configDir) {
            try? FileManager.default.createDirectory(atPath: configDir, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Note: ~/.config/quotes.txt will be created when user first selects a quote file
        
        return configPath
    }
    
    @objc func browseForFile(_ sender: NSButton) {
        NSLog("Browse button clicked!")
        
        let openPanel = NSOpenPanel()
        openPanel.title = "Choose Quote File"
        openPanel.prompt = "Choose"
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowedFileTypes = ["txt"]
        
        openPanel.begin { [weak self] response in
            if response == .OK, let url = openPanel.url {
                self?.quoteFilePath = url.path
                self?.filePathTextField.stringValue = url.path
            }
        }
    }
    
    @objc func ok(_ sender: NSButton) {
        // Update the file path from text field
        quoteFilePath = filePathTextField.stringValue
        
        let defaults = ScreenSaverDefaults(forModuleWithName: "QuoteSaver")
        defaults?.set(quoteFilePath, forKey: "QuoteFilePath")
        defaults?.synchronize()
        
        // Send distributed notification to notify all running screensaver instances
        DistributedNotificationCenter.default.post(
            name: .init("QuoteSaverPreferencesChanged"),
            object: nil
        )
        
        // Try multiple approaches to close the window
        closeWindow()
    }
    
    @objc func cancel(_ sender: NSButton) {
        // Close without saving
        closeWindow()
    }
    
    private func closeWindow() {
        guard let window = self.window else { return }
        
        // Try different approaches to close the sheet/window
        if let parent = window.sheetParent {
            parent.endSheet(window)
        } else if window.isModalPanel {
            NSApp.stopModal()
            window.orderOut(self)
        } else {
            window.performClose(self)
        }
    }
    
    @objc func filePathChanged(_ sender: NSTextField) {
        quoteFilePath = sender.stringValue
    }
}