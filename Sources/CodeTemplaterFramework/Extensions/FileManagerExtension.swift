//
//  FileManagerExtension.swift
//  CodeTemplater
//
//  Created by Daniel Cech on 16/07/2020.
//

import Foundation

extension FileManager {
    /// Test for folder existence with URL parameter
    func directoryExists(atUrl url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = fileExists(atPath: url.path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }

    /// Test for folder existence with path parameter
    func directoryExists(atPath: String) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: atPath, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
}
