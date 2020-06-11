//
//  main.swift
//  icloud-stats
//
//  Created by Günther Eberl on 2020-04-21.
//  Copyright © 2020 Günther Eberl. All rights reserved.
//

import Foundation
import ArgumentParser

// e.g. run like this: ./icloud-stats --src="/Users/guenther/Downloads/"

// https://github.com/apple/swift-argument-parser

struct CloudStatsOptions: ParsableArguments {
    @Flag(name: .long, help: "Print version and exit.")
    var version: Bool
    
    @Option(default: "",
            help: ArgumentHelp("Override source path.", valueName: "path"))
    var src: String
    
    // --help is automatically included
}

let options = CloudStatsOptions.parseOrExit()

if options.version == true {
    print("Version is 0.0.2")
} else {

    //if let validSrcPath = options.src {
    //    basePath = validSrcPath
    // }

    do {
        let documentsUrl = try FileManager.default.url(for: .documentDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: false)

        let childDirs = getChildDirs(url: documentsUrl)
        var overall = dirOverall(maxLengthPath: "PATH".count,
                                 maxLengthDirs: "DIRS".count,
                                 maxLengthFiles: "FILES".count,
                                 maxLengthPlaceholders: "PLACEHOLDERS".count,
                                 maxLengthHidden: "HIDDEN".count,
                                 maxLengthSizeFiles: "SIZE".count,
                                 maxLengthSizeOffloaded: "OFFLOADED".count,
                                 maxLengthTotal: "TOTAL".count,
                                 totalDirs: 0,
                                 totalFiles: 0,
                                 totalPlaceholders: 0,
                                 totalHidden: 0,
                                 totalSizeFiles: 0,
                                 totalSizeOffloaded: 0,
                                 stats: [])
        
        for childDir in childDirs {
            let childStats = walkDir(baseURL: childDir)
            
            if childStats.path.count > overall.maxLengthPath {
                overall.maxLengthPath = childStats.path.count
            }
            
            if String(childStats.numberOfDirs).count > overall.maxLengthDirs {
                overall.maxLengthDirs = String(childStats.numberOfDirs).count
            }
            
            if String(childStats.numberOfFiles).count > overall.maxLengthFiles {
                overall.maxLengthFiles = String(childStats.numberOfFiles).count
            }
            
            if String(childStats.numberOfPlaceholders).count > overall.maxLengthPlaceholders {
                overall.maxLengthPlaceholders = String(childStats.numberOfPlaceholders).count
            }
            
            if String(childStats.numberOfHidden).count > overall.maxLengthHidden {
                overall.maxLengthHidden = String(childStats.numberOfHidden).count
            }
            
            if getSizeString(byteCount: childStats.sizeFiles).count > overall.maxLengthSizeFiles {
                overall.maxLengthSizeFiles = getSizeString(byteCount: childStats.sizeFiles).count
            }
            
            if getSizeString(byteCount: childStats.sizeOffloaded).count > overall.maxLengthSizeOffloaded {
                overall.maxLengthSizeOffloaded = getSizeString(byteCount: childStats.sizeOffloaded).count
            }
            
            overall.totalDirs += childStats.numberOfDirs
            overall.totalFiles += childStats.numberOfFiles
            overall.totalPlaceholders += childStats.numberOfPlaceholders
            overall.totalHidden += childStats.numberOfHidden
            overall.totalSizeFiles += childStats.sizeFiles
            overall.totalSizeOffloaded += childStats.sizeOffloaded
            
            overall.stats.append(childStats)
        }
        
        printStats(overall: overall)

    } catch {
        print(error.localizedDescription)
    }
}
