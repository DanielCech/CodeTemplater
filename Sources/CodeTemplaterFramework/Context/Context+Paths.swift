//
//  Context+Paths.swift
//  codeTemplater
//
//  Created by Daniel Cech on 13/09/2020.
//

import Files
import Foundation

// MARK: - Paths

extension Context {
    /// Setup paths for project
    func setupProjectPaths() throws {
        if optionalStringValue(.projectPath) == nil {
            self[.projectPath] = try Folder.current.subfolder(named: "templater").subfolder(named: "Generate").path         // TODO: check, is it ok?
        }
        
        guard let unwrappedProjectPath = optionalStringValue(.projectPath) else {
            throw CodeTemplaterError.moreInfoNeeded(message: "projectPath is missing")
        }
        
        guard FileManager.default.directoryExists(atPath: stringValue(.projectPath)) else {
            throw CodeTemplaterError.folderNotFound(message: "projectPath folder \(stringValue(.projectPath)) does not exist")
        }
        
        if optionalStringValue(.sourcesPath) == nil {
            // Derive sources path from project path and project name
            if let unwrappedProjectName = optionalStringValue(.projectName) {
                self[.sourcesPath] = unwrappedProjectPath.appendingPathComponent(path: unwrappedProjectName)
            }
            else {
                throw CodeTemplaterError.moreInfoNeeded(message: "unknown sourcesPath")
            }
        }
        
        if !FileManager.default.directoryExists(atPath: stringValue(.sourcesPath)) {
            throw CodeTemplaterError.folderNotFound(message: "sourcesPath folder \(stringValue(.sourcesPath)) does not exist. Parameter `sourcesPath` describes the path where project sources are located. It is one level deeper than projectPath. Is often generated from `projectPath` by appending `projectName`")
        }

        if optionalStringValue(.testsPath) == nil {
            // Derive sources path from project path and project name
            if let unwrappedProjectName = optionalStringValue(.projectName) {
                self[.testsPath] = unwrappedProjectPath.appendingPathComponent(path: unwrappedProjectName + " Tests")
            }
        }
        
        if !FileManager.default.directoryExists(atPath: stringValue(.testsPath)) {
            Logger.log(indent: 0, string: "⚠️ Folder testsPath does not exist.")
        }

        if let unwrappedLocationPath = optionalStringValue(.locationPath) {
            // If path is absolute
            if unwrappedLocationPath.starts(with: "/") {
                self[.locationPath] = unwrappedLocationPath
            }
            else {
                self[.locationPath] = unwrappedProjectPath.appendingPathComponent(path: unwrappedLocationPath)
            }
        }
        
        if let unwrappedLocationPath = optionalStringValue(.locationPath), !FileManager.default.directoryExists(atPath: unwrappedLocationPath) {
            Logger.log(indent: 0, string: "🟢 locationPath \(unwrappedLocationPath) does not exist. Create? [yN] ", terminator: "")
            if readLine() == "y" {
                try FileManager.default.createDirectory(atPath: unwrappedLocationPath, withIntermediateDirectories: true, attributes: nil)
            }
            else {
                throw CodeTemplaterError.folderNotFound(message: "locationPath folder \(unwrappedLocationPath) does not exist")
            }
        }
    }

    /// Setup paths for script
    func setupScriptPaths() throws {
        // TODO: create Templates folder if it doesn't exist

        if optionalStringValue(.scriptPath) == nil {
            self[.scriptPath] = try? Folder.current.subfolder(named: "templater").path
        }

        if let unwrappedScriptPath = optionalStringValue(.scriptPath) {
            if self[.templatePath] == nil {
                self[.templatePath] = unwrappedScriptPath.appendingPathComponent(path: "Templates")
            }
            
            if self[.templateScriptPath] == nil {
                self[.templateScriptPath] = unwrappedScriptPath.appendingPathComponent(path: "TemplateScripts")
            }
            
            if self[.generatePath] == nil {
                self[.generatePath] = unwrappedScriptPath.appendingPathComponent(path: "Generate")
            }
            
            if self[.validatePath] == nil {
                self[.validatePath] = unwrappedScriptPath.appendingPathComponent(path: "Validate")
            }
            
            if self[.preparePath] == nil {
                self[.preparePath] = unwrappedScriptPath.appendingPathComponent(path: "Prepare")
            }
        }
        else {
            throw CodeTemplaterError.moreInfoNeeded(message: "scriptPath is missing")
        }

        // Create folders if needed
        try? FileManager.default.createDirectory(atPath: stringValue(.generatePath), withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.createDirectory(atPath: stringValue(.validatePath), withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.createDirectory(atPath: stringValue(.preparePath), withIntermediateDirectories: true, attributes: nil)
    }
}
