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
            basePath = documentsUrl.absoluteString
            basePath = basePath!.deletingPrefix("file://")
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
    // var numberOfPlaceholders = 0
    var sizeOfFiles: Int64 = 0
    
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
    
    print("Results:")
    print("  Number of directories:  ", numberOfDirs)
    print("  Number of files:        ", numberOfFiles)
    print("  Number of hidden files: ", numberOfHiddenFiles)
    print("  Total size of files:    ", sizeOfFiles)
}
