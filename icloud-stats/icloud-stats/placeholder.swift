//
//  placeholder.swift
//  icloud-stats
//
//  Created by Günther Eberl on 2020-04-25.
//  Copyright © 2020 Günther Eberl. All rights reserved.
//

import Foundation

struct iCloudPlist: Codable {
    var NSURLFileResourceTypeKey: String
    var NSURLFileSizeKey: Int64
    var NSURLNameKey: String
}

func getSizeOfOffloadedContent(url: URL) -> Int64 {
    guard let xml = FileManager.default.contents(atPath: url.path) else {
        print(url)
        return 0
    }
  
    if let plist = try? PropertyListDecoder().decode(iCloudPlist.self, from: xml) {
        return plist.NSURLFileSizeKey
    }
    return 0
}
