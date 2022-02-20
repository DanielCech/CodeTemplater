//
//  PublicInterface.swift
//  FileSmith
//
//  Created by Daniel Cech on 10/09/2020.
//

import Foundation

/// Public interface to CodeTemplater functions
public class CodeTemplater {
    public init() {
        // TODO: set level to .error for final builds
        log.setup(
            level: .error,
            showLogIdentifier: true,
            showFunctionName: true,
            showThreadName: false,
            showLevel: true,
            showFileNames: true,
            showLineNumbers: true,
            showDate: false,
            writeToFile: nil,
            fileLevel: nil
        )
    }
    
    /// Initial steps for proper script configuration
    public func initializeContext() throws -> Context {
        return try scriptSetup.initializeContext()
    }
    
    /// Basic usage information
    public func showUsageText() {
        scriptSetup.showUsageText()
    }
    
    /// Initialization of componentes with simple dependency injection
    public func initializeComponents() {
        scriptSetup.initializeComponents()
    }
    
    /// Initialization of context from dictionary
    public func context(fromDictionary dictionary: [String: Any]) -> Context {
        return Context(dictionary: dictionary)
    }

    /// Generate code using template with context in json file
    public func generateCode(context: Context) throws {
        try scriptSetup.generateCode(context: context)
    }
    
    /// Save context to file lastContext.json
    public func saveContext(_ context: Context) throws {
        let lastContextPath = context.stringValue(.scriptPath).appendingPathComponent(path: "lastContext.json")
        try context.save(toFile: lastContextPath)
    }
}
