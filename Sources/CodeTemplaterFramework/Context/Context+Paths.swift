//
//  Context+Paths.swift
//  codeTemplater
//
//  Created by Daniel Cech on 13/09/2020.
//

import Foundation
import Files

// MARK: - Paths

extension Context {
    /// Setup paths for project
    func setupProjectPaths() throws {
        if optionalStringValue(.projectPath) == nil {
            self[.projectPath] = try Folder.current.subfolder(named: "templater").subfolder(named: "Generate").path
        }

        if optionalStringValue(.locationPath) == nil {
            self[.locationPath] = try Folder.current.subfolder(named: "templater").subfolder(named: "Generate").path
        }

        guard let unwrappedProjectPath = optionalStringValue(.projectPath) else {
            throw CodeTemplaterError.moreInfoNeeded(message: "projectPath is missing")
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

        if let unwrappedLocationPath = optionalStringValue(.locationPath) {
            // If path is absolute
            if unwrappedLocationPath.starts(with: "/") {
                self[.locationPath] = unwrappedLocationPath
            }
            else {
                self[.locationPath] = unwrappedProjectPath.appendingPathComponent(path: unwrappedLocationPath)
            }
        }
        else {
            // TODO: check - location path is not sometimes needed
            throw CodeTemplaterError.moreInfoNeeded(message: "locationPath is missing")
        }
    }

    /// Setup paths for script
    func setupScriptPaths() throws {
        // TODO: create Templates folder if it doesn't exist

        if optionalStringValue(.scriptPath) == nil {
            self[.scriptPath] = try? Folder.current.subfolder(named: "templater").path
        }

        if let unwrappedScriptPath = optionalStringValue(.scriptPath) {
            self[.templatePath] = unwrappedScriptPath.appendingPathComponent(path: "Templates")
            self[.generatePath] = unwrappedScriptPath.appendingPathComponent(path: "Generate")
            self[.validatePath] = unwrappedScriptPath.appendingPathComponent(path: "Validate")
            self[.preparePath] = unwrappedScriptPath.appendingPathComponent(path: "Prepare")
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
