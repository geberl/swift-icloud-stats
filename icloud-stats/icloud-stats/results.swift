//
//  results.swift
//  icloud-stats
//
//  Created by Günther Eberl on 2020-04-25.
//  Copyright © 2020 Günther Eberl. All rights reserved.
//

import Foundation

func printHeadline(overall: dirOverall) {
    var headline: String = ""
    headline += "PATH".rPad(toLength: overall.maxLengthPath + 3, withPad: " ")
    headline += "DIRS".rPad(toLength: overall.maxLengthDirs + 3, withPad: " ")
    headline += "FILES".rPad(toLength: overall.maxLengthFiles + 3, withPad: " ")
    headline += "PLACEHOLDERS".rPad(toLength: overall.maxLengthPlaceholders + 3, withPad: " ")
    headline += "HIDDEN".rPad(toLength: overall.maxLengthHidden + 3, withPad: " ")
    headline += "SIZE".rPad(toLength: overall.maxLengthSizeFiles + 3, withPad: " ")
    headline += "OFFLOADED".rPad(toLength:  overall.maxLengthSizeOffloaded + 3, withPad: " ")
    headline += "TOTAL"
    print(headline)
}

func printDirStats(overall: dirOverall, stats: dirStats) {
    var pathInfo: String = ""
    pathInfo += stats.path.rPad(toLength: overall.maxLengthPath + 3, withPad: " ")
    pathInfo += String(stats.numberOfDirs).rPad(toLength: overall.maxLengthDirs + 3, withPad: " ")
    pathInfo += String(stats.numberOfFiles).rPad(toLength: overall.maxLengthFiles + 3, withPad: " ")
    pathInfo += String(stats.numberOfPlaceholders).rPad(toLength: overall.maxLengthPlaceholders + 3, withPad: " ")
    pathInfo += String(stats.numberOfHidden).rPad(toLength: overall.maxLengthHidden + 3, withPad: " ")
    pathInfo += getSizeString(byteCount: stats.sizeFiles).rPad(toLength: overall.maxLengthSizeFiles + 3, withPad: " ")
    pathInfo += getSizeString(byteCount: stats.sizeOffloaded).rPad(toLength: overall.maxLengthSizeOffloaded + 3, withPad: " ")
    pathInfo += getSizeString(byteCount: stats.sizeFiles + stats.sizeOffloaded)
    print(pathInfo)
}

func printTotalStats(overall: dirOverall) {
    var total: String = ""
    total += "TOTAL".rPad(toLength: overall.maxLengthPath + 3, withPad: " ")
    total += String(overall.totalDirs).rPad(toLength: overall.maxLengthDirs + 3, withPad: " ")
    total += String(overall.totalFiles).rPad(toLength: overall.maxLengthFiles + 3, withPad: " ")
    total += String(overall.totalPlaceholders).rPad(toLength: overall.maxLengthPlaceholders + 3, withPad: " ")
    total += String(overall.totalHidden).rPad(toLength: overall.maxLengthHidden + 3, withPad: " ")
    total += getSizeString(byteCount: overall.totalSizeFiles).rPad(toLength: overall.maxLengthSizeFiles + 3, withPad: " ")
    total += getSizeString(byteCount: overall.totalSizeOffloaded).rPad(toLength: overall.maxLengthSizeOffloaded + 3, withPad: " ")
    total += getSizeString(byteCount: overall.totalSizeFiles + overall.totalSizeOffloaded)
    print(total)
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
