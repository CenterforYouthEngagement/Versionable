//
//  Versionable+SaveToFile.swift
//  
//
//  Created by Jeremy Kelleher on 1/18/23.
//  Adapted from https://github.com/krzysztofzablocki/Versionable/blob/master/Sources/Versionable/Versionable.swift

import Foundation

#if DEBUG
public extension Versionable where Self: Encodable {

    /// Create a JSON file with the data from `self`.
    /// Helpful when creating tests for the latest version of a `Model`.
    func saveJSONToFile() throws {
        
        let usernameComponents = NSHomeDirectory().components(separatedBy: "/")
        guard usernameComponents.count > 2 else { fatalError() }
        let username = usernameComponents[2]
        let desktopPath = "/Users/\(username)/Desktop/"
        
        let encoded = try JSONEncoder().encode(self)
        try encoded.write(to: URL(fileURLWithPath: "\(desktopPath)/\(Self.self)_\(version).json"), options: .atomicWrite)
    }
    
}
#endif
