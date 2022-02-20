//
//  PublicInterface.swift
//  FileSmith
//
//  Created by Daniel Cech on 10/09/2020.
//

import Foundation

/// Public interface to CodeTemplater functions
final public class CodeTemplater {
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
        
        try? Installer().handleInstalation()
    }

    /// Initial steps for proper script configuration
    public func initializeContext() throws -> Context {
        return try scriptSetup.initializeContext()
    }

    public func process(context: Context) throws {
        try scriptSetup.process(context: context)
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

    /// Validate the particular template - the test whether generated code is compilable
    public func validate(context: Context) throws {
        // TODO: fix
//        try scriptSetup.validate(context: context)
    }

    /// The process of template preparation from existing code
    public func prepareTemplate(context: Context) throws {
        // For prepare mode is parameter inPlace on by default
        context[.inPlace] = true
        try scriptSetup.prepareTemplate(context: context)
    }

    /// Save context to file lastContext.json
    public func saveContext(_ context: Context) throws {
        var contextFileName: String
        if let unwrappedName = context[.name] {
            if let unwrappedTemplate = context[.template] {
                let modifiedTemplate = unwrappedTemplate.replacingOccurrences(of: "/", with: "\\")
                contextFileName = unwrappedName + "-(\(modifiedTemplate)).json"
            }
            else {
                contextFileName = unwrappedName + ".json"
            }
        }
        else {
            contextFileName = "lastContext.json"
        }

        let lastContextPath = context.stringValue(.scriptPath).appendingPathComponent(path: "Contexts").appendingPathComponent(path: contextFileName)
        try context.save(toFile: lastContextPath)
    }
}
