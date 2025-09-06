# QuoteSaver

A macOS screensaver that displays random programming quotes from a text file.

## Features

- Displays random quotes from a configurable text file
- Supports multi-line quotes with `\n` newline characters
- Configurable quote file path through System Preferences
- Clean, minimalist display with white text on black background
- Changes quotes every 10 seconds
- Works on macOS 10.15 (Catalina) and later
- Unsigned distribution (no developer license required)

## Building

### Prerequisites

- macOS with Xcode installed
- Command line tools: `xcode-select --install`

### Build Steps

1. Clone or download this repository
2. Open Terminal and navigate to the project directory
3. Run the build script:
   ```bash
   ./simple_build.sh
   ```

This will create `QuoteSaver.saver` in the current directory.

### Manual Build (Alternative)

If the build script doesn't work, you can build manually:

1. Open `QuoteSaver.xcodeproj` in Xcode
2. Select the QuoteSaver scheme
3. Build for Release (⌘+B)
4. The built screensaver will be in the DerivedData folder

## Installation

### Automatic Installation
1. Double-click `QuoteSaver.saver`
2. Click "Install" when prompted

### Manual Installation
1. Copy `QuoteSaver.saver` to `~/Library/Screen Savers/`
2. Go to System Preferences → Desktop & Screen Saver → Screen Saver
3. Select "Quote Saver" from the list

## Configuration

1. In System Preferences → Desktop & Screen Saver → Screen Saver
2. Select "Quote Saver"
3. Click "Options..."
4. Browse to select your quote file, or enter the path manually
5. Click "OK" to save

## Quote File Format

The screensaver expects a plain text file with one quote per line. Each line should contain:

```
Quote text\n—Author Name
```

### Examples:
```
No resolution doesn't mean no progress.\n—Elizabeth Aguilar-Barnett
A good programmer is someone who always looks both ways before crossing a one-way street.\n—Doug Linder
Don’t worry if it doesn't work right. If everything did, you’d be out of a job.\n—Mosher’s Law of Software Engineering
```

### Newlines in Quotes
Use `\n` in your quote text for line breaks:
```
First line of quote\nSecond line of quote\n—Author Name
```

## Default Quote File

By default, the screensaver looks for `codeQuotes.txt` in the same directory as the screensaver. You can change this path in the configuration panel.

## Troubleshooting

### "QuoteSaver.saver" cannot be opened because it is from an unidentified developer

This happens because the screensaver is unsigned. To install:

1. Right-click on `QuoteSaver.saver`
2. Select "Open" from the context menu
3. Click "Open" when prompted
4. Follow the installation prompts

### No quotes appear

1. Check that your quote file exists at the configured path
2. Verify the quote file format (one quote per line, pipe-separated)
3. Open Screen Saver Options and verify the file path is correct

### Quotes appear corrupted

- Ensure your quote file uses UTF-8 encoding
- Check for special characters that might not display correctly

## Development

The project consists of:

- `QuoteSaverView.swift` - Main screensaver view and logic
- `ConfigureSheet.swift` - Configuration panel controller
- `ConfigureSheet.xib` - Configuration panel UI
- `Info.plist` - Bundle configuration
- `QuoteSaver.xcodeproj` - Xcode project files

## License

This project is open source and available for anyone to use, modify, and distribute.

## Contributing

Feel free to submit issues, feature requests, or pull requests to improve QuoteSaver.
