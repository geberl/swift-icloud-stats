# swift-icloud-stats

*A macOS  terminal app that shows stats about your iCloud Documents directory*

![Swift](https://img.shields.io/badge/swift-5.3-brightgreen.svg)
![Xcode](https://img.shields.io/badge/xcode-12.4-brightgreen.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)

## Usage

```shell
# Scan and show stats
./icloud-stats

# Show auto-detected documents directory
./icloud-stats --show-src

# Scan and show stats of another directory
./icloud-stats --src "/Users/guenther/Downloads/"

# Show help
./icloud-stats --help
```

## Screenshots

![screenshot1](/screenshots/1.png?raw=true "Screenshot 1")

![screenshot2](/screenshots/2.png?raw=true "Screenshot 2")

## Dependencies

- [https://github.com/apple/swift-argument-parser](https://github.com/apple/swift-argument-parser)

## Why?

- Offloaded files only exist as a placeholder `*.plist` files on your drive
- These files only have a few bytes
- Because of this tools like **DaisyDisk** are of no use to identify big files or get an overview about your space usage
