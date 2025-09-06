/*
 * QuoteSaver - A macOS screensaver for displaying text quotes
 * 
 * Authors: Claude (Anthropic) & flare576
 * License: Open Source
 */

import ScreenSaver
import Cocoa
import Foundation

class QuoteSaverView: ScreenSaverView {
    private var timer: Timer?
    private var quotes: [Quote] = []
    private var currentQuote: Quote?
    private var quoteFilePath: String = ""
    
    struct Quote {
        let text: String
        let author: String
        
        var displayText: String {
            return text
        }
    }
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        self.animationTimeInterval = 1.0 / 30.0
        loadQuoteFilePath()
        loadQuotes()
        selectRandomQuote()
        setupNotifications()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.animationTimeInterval = 1.0 / 30.0
        loadQuoteFilePath()
        loadQuotes()
        selectRandomQuote()
        setupNotifications()
    }
    
    override func startAnimation() {
        super.startAnimation()
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            // Check for preference changes each time we select a new quote
            self.checkForPreferenceChanges()
            self.selectRandomQuote()
            self.needsDisplay = true
        }
    }
    
    override func stopAnimation() {
        super.stopAnimation()
        timer?.invalidate()
        timer = nil
    }
    
    override func draw(_ rect: NSRect) {
        NSColor.black.setFill()
        rect.fill()
        
        guard let quote = currentQuote else { return }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.white,
            .font: NSFont.systemFont(ofSize: isPreview ? 10 : 32)
        ]
        
        let attributedString = NSAttributedString(string: quote.displayText, attributes: attributes)
        
        // Calculate available width with margins
        let margin: CGFloat = 40
        let availableWidth = bounds.width - (margin * 2)
        
        // Calculate text size with wrapping constraint
        let constraintSize = NSSize(width: availableWidth, height: CGFloat.greatestFiniteMagnitude)
        let textRect = attributedString.boundingRect(
            with: constraintSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading]
        )
        
        // Center the text on screen
        let x = (bounds.width - textRect.width) / 2
        let y = (bounds.height - textRect.height) / 2
        let drawRect = NSRect(x: x, y: y, width: availableWidth, height: textRect.height)
        
        attributedString.draw(in: drawRect)
    }
    
    override func animateOneFrame() {
        needsDisplay = true
    }
    
    override var hasConfigureSheet: Bool {
        return true
    }
    
    private var configSheet: ConfigureSheet?
    
    override var configureSheet: NSWindow? {
        configSheet = ConfigureSheet()
        configSheet?.loadWindow()
        return configSheet?.window
    }
    
    private func loadQuoteFilePath() {
        let defaults = ScreenSaverDefaults(forModuleWithName: "QuoteSaver")
        quoteFilePath = defaults?.string(forKey: "QuoteFilePath") ?? getDefaultQuoteFilePath()
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
    
    private func loadQuotes() {
        quotes.removeAll()
        
        guard FileManager.default.fileExists(atPath: quoteFilePath) else {
            quotes.append(Quote(text: "Quote file not found at: \(quoteFilePath)", author: "QuoteSaver"))
            return
        }
        
        do {
            let content = try String(contentsOfFile: quoteFilePath, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            for line in lines {
                let text = line.replacingOccurrences(of: "\\n", with: "\n")
                quotes.append(Quote(text: text, author: ""))
            }
            
            if quotes.isEmpty {
                quotes.append(Quote(text: "No content found in file", author: "QuoteSaver"))
            }
        } catch {
            quotes.append(Quote(text: "Error reading quote file: \(error.localizedDescription)", author: "QuoteSaver"))
        }
    }
    
    private func selectRandomQuote() {
        guard !quotes.isEmpty else {
            // Fallback quote if no quotes loaded
            currentQuote = Quote(text: "No quotes loaded. Check file: \(quoteFilePath)", author: "")
            return
        }
        currentQuote = quotes.randomElement()
    }
    
    func updateQuoteFilePath(_ newPath: String) {
        quoteFilePath = newPath
        let defaults = ScreenSaverDefaults(forModuleWithName: "QuoteSaver")
        defaults?.set(newPath, forKey: "QuoteFilePath")
        defaults?.synchronize()
        loadQuotes()
        selectRandomQuote()
        needsDisplay = true
    }
    
    private func checkForPreferenceChanges() {
        let defaults = ScreenSaverDefaults(forModuleWithName: "QuoteSaver")
        // Force sync from disk to get latest changes from other processes
        defaults?.synchronize()
        let newPath = defaults?.string(forKey: "QuoteFilePath") ?? getDefaultQuoteFilePath()
        
        if newPath != quoteFilePath {
            quoteFilePath = newPath
            loadQuotes()
            selectRandomQuote()
            needsDisplay = true
        }
    }
    
    private func setupNotifications() {
        // Listen for preference changes (local process)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(preferencesChanged),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
        
        // Listen for distributed notifications (cross-process)
        DistributedNotificationCenter.default.addObserver(
            self,
            selector: #selector(preferencesChanged),
            name: .init("QuoteSaverPreferencesChanged"),
            object: nil
        )
    }
    
    @objc private func preferencesChanged() {
        checkForPreferenceChanges()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        DistributedNotificationCenter.default.removeObserver(self)
    }
}