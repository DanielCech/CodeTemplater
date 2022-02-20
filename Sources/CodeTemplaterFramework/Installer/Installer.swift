//
//  Installer.swift
//  CodeTemplaterFramework
//
//  Created by Daniel Cech on 06/02/2021.
//

import Foundation

final class Installer {
    
    func handleInstalation() throws {
        if CommandLine.arguments.count == 2 && CommandLine.arguments[1] == "init" {
            try setup()
            exit(0)
        }
    }
    
    private func setup() throws {
        createDirectories()
        try createCodeTemplaterJson()
        try modifyGitIgnore()
    }
    
    private func createDirectories() {
        try? FileManager.default.createDirectory(atPath: "templater/Contexts", withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.createDirectory(atPath: "templater/Generate", withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.createDirectory(atPath: "templater/Prepare", withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.createDirectory(atPath: "templater/Templates", withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.createDirectory(atPath: "templater/TemplateScripts", withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.createDirectory(atPath: "templater/Validate", withIntermediateDirectories: true, attributes: nil)
    }
    
    private func createCodeTemplaterJson() throws {
        let year = Calendar.current.component(.year, from: Date())
        let projectName = FileManager.default.currentDirectoryPath.lastPathComponent
        
        let templaterFolder = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("templater")
        
        let codeTemplaterJSON = """
            {
              "projectName": "\(projectName)",
              "copyright": "Copyright � \(year) STRV. All rights reserved."
            }
            """
        try codeTemplaterJSON.write(to: templaterFolder.appendingPathComponent("CodeTemplater.json"), atomically: true, encoding: .utf8)
        
        let codeTemplaterPersonalJSON = """
            {
              "author": "",
              "projectPath": "\(FileManager.default.currentDirectoryPath)"
            }
            """
        try codeTemplaterPersonalJSON.write(to: templaterFolder.appendingPathComponent("CodeTemplaterPersonal.json"), atomically: true, encoding: .utf8)
        
        Logger.log(indent: 0, string: "🟢 Please update files CodeTemplater.json and CodeTemplaterPersonal.json in templater folder.")
    }
    
    private func modifyGitIgnore() throws {
        let gitIgnoreURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(".gitignore")
        var gitIgnoreContents = ""
        
        if FileManager.default.fileExists(atPath: gitIgnoreURL.path) {
            try gitIgnoreContents = String(contentsOf: gitIgnoreURL, encoding: .utf8)
            
            if gitIgnoreContents.contains("# CodeTemplater") {
                return
            }
        }
        
        gitIgnoreContents += """

            # CodeTemplater
            templater/Generate/*
            templater/Validate/*
            templater/Prepare/*
            templater/Contexts/*
            templater/CodeTemplaterPersonal.json
            """
        
        try gitIgnoreContents.write(to: gitIgnoreURL, atomically: true, encoding: .utf8)
    }
}
