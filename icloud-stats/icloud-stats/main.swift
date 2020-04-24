//
//  main.swift
//  icloud-stats
//
//  Created by Günther Eberl on 2020-04-21.
//  Copyright © 2020 Günther Eberl. All rights reserved.
//

import Foundation
import Guaka

// Docs: https://github.com/nsomar/Guaka
// And: https://getguaka.github.io/index.html

// e.g. run like this: ./icloud-stats --src="/Users/guenther/Downloads/"

let version = Flag(shortName: "v",
                   longName: "version",
                   value: false,
                   description: "Print version and exit")

let srcPath = Flag(shortName: "src",
                   longName: "source",
                   type: String.self,
                   description: "Specifies the source path")

let command = Command(usage: "icloud-stats", flags: [version, srcPath]) { flags, args in
    if let hasVersion = flags.getBool(name: "version"), hasVersion == true {
        print("Version is 0.0.1")
        return
    }
    
    var basePath: String?
    if let validSrcPath = flags.getString(name: "source") {
        basePath = validSrcPath
    } else {
        do {
            let documentsUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask,
                                                           appropriateFor: nil, create: false)
            basePath = documentsUrl.path
        } catch {
            print(error.localizedDescription)
        }
    }
    
    if let validBasePath = basePath {
        walkDir(basePath: validBasePath)
        // print("Walk dir now", validBasePath)
    } else {
        print("No base path to walk")
    }
    
    // print("You passed \(args) to your Guaka app!")
}

command.execute()

func walkDir(basePath: String) {
    // Taken from: https://github.com/geberl/swift-localstorage/blob/b169f9348d0386fdc4c4d0b75f8cdb52a7085a47/LocalStorage/Local%20Storage/Common.swift#L350
    
    var numberOfDirs = 0
    var numberOfFiles = 0
    var numberOfHiddenFiles = 0
    var numberOfPlaceholders = 0
    var sizeOfFiles: Int64 = 0
    var sizeOfPlacholderContent: Int64 = 0
    
    let fileManager = FileManager.default
    guard let enumerator: FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: basePath) else {
        print("Directory not found")
        return
    }
    
    while let element = enumerator.nextObject() as? String {
        var elementURL: URL = URL(fileURLWithPath: basePath)
        elementURL.appendPathComponent(element)
        
        var fileSize: Int64
        do {
            let attr = try fileManager.attributesOfItem(atPath: elementURL.path)
            fileSize = attr[FileAttributeKey.size] as! Int64
            // Note: FileAttributeKey.type is useless, just contains file/folder, not UTI.
        } catch {
            fileSize = 0
        }
        sizeOfFiles += fileSize
        
        if let fileType: String = elementURL.typeIdentifier {
            if fileType == "com.apple.icloud-file-fault" {
                numberOfPlaceholders += 1
                sizeOfPlacholderContent += getSizeOfPlaceholderContent(url: elementURL)
            }
        }
        
        if let values = try? elementURL.resourceValues(forKeys: [.isDirectoryKey]) {
            if values.isDirectory! {
                numberOfDirs += 1
            } else {
                if element.starts(with: ".") {
                    numberOfHiddenFiles += 1
                } else {
                    numberOfFiles += 1
                }
            }
        }
    }
    
    print("Count:")
    print("  Number of directories:       ", numberOfDirs)
    print("  Number of downloaded files:  ", numberOfFiles)
    print("  Number of placeholder files: ", numberOfPlaceholders)
    print("  Number of hidden files:      ", numberOfHiddenFiles)
    print("  Total:                       ", numberOfDirs + numberOfFiles + numberOfPlaceholders + numberOfHiddenFiles)
    print("Size:")
    print("  Downloaded:                  ", getSizeString(byteCount: sizeOfFiles))
    print("  In placeholders:             ", getSizeString(byteCount: sizeOfPlacholderContent))
    print("  Total:                       ", getSizeString(byteCount: sizeOfFiles + sizeOfPlacholderContent))
    print("")
}

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

extension URL {
    var typeIdentifier: String? {
        return (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier
    }
}

func getSizeString(byteCount: Int64) -> String {
    // Get a human readable size string according to user preferences.
    
    let unit: String = "all"
    
    if byteCount == 0 {
        if unit == "all" {
            return "0 bytes"
        }
        return "0 " + unit
    }
    
    let byteCountFormatter = ByteCountFormatter()
    if unit == "bytes" {
        byteCountFormatter.allowedUnits = .useBytes
    } else if unit == "KB" {
        byteCountFormatter.allowedUnits = .useKB
    } else if unit == "MB" {
        byteCountFormatter.allowedUnits = .useMB
    } else if unit == "GB" {
        byteCountFormatter.allowedUnits = .useGB
    } else {
        byteCountFormatter.allowedUnits = .useAll
    }
    byteCountFormatter.countStyle = .file
    
    return byteCountFormatter.string(fromByteCount: byteCount)
}

func getSizeOfPlaceholderContent(url: URL) -> Int64 {
    guard let xml = FileManager.default.contents(atPath: url.path) else {
        print(url)
        return 0
    }
  
    if let plist = try? PropertyListDecoder().decode(iCloudPlist.self, from: xml) {
        return plist.NSURLFileSizeKey
    }
    return 0
}

struct iCloudPlist: Codable {
    var NSURLFileResourceTypeKey: String
    var NSURLFileSizeKey: Int64
    var NSURLNameKey: String
}
