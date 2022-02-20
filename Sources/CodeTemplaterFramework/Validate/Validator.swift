//
//  Validator.swift
//  CodeTemplater
//
//  Created by Daniel Cech on 27/06/2020.
//

import Foundation

import Files
import ScriptToolkit

/// Power operator - used for counting the possible combinations
precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ^^ : PowerPrecedence
func ^^ (radix: Int, power: Int) -> Int {
    return Int(pow(Double(radix), Double(power)))
}

/// Validation the templates - test whether they can be compiled separately with all possible combinations of switches
public final class Validator {
    /// Dependencies
    private var templates: Templates
    private var generator: Generator
    private var parameterProcessor: ParameterProcessor

    init(templates: Templates, generator: Generator, parameterProcessor: ParameterProcessor) {
        self.templates = templates
        self.generator = generator
        self.parameterProcessor = parameterProcessor
    }

    /// Validate all templates
    func validateTemplates(context: Context) throws {
        for template in try templates.templateTypes(context: context).keys {
            try validate(template: template, context: context)
        }
    }

    /// Validate particular template
    func validate(template: Template, context: Context) throws {
        Logger.log(indent: 0, string: "🔎 \(template)")

        // Empty validation folder
        let validationFolder = try Folder(path: context.stringValue(.validatePath))
        try validationFolder.empty(includingHidden: true)

        // Load template settings
        let context = defaultContext()
        let templateInfo = try templates.templateInfo(for: template, context: context)

        Logger.log(indent: 0, string: "✂️ template \(template):")

        // Update default context with settings context
        for key in templateInfo.validationContext.dictionary.keys {
            context.dictionary[key] = templateInfo.validationContext.dictionary[key]
        }

        let switches = templateInfo.parameters.filter { $0.type == .bool }.map { $0.name }

        // Series of switches values - all combinations
        for index in 0 ..< 2 ^^ switches.count {
            let unsignedIndex = UInt32(index)

            for (switchIndex, switchElement) in switches.enumerated() {
                let unsignedSwitchBit: UInt32 = 1 << switchIndex
                if (unsignedIndex & unsignedSwitchBit) > 0 {
                    context.dictionary[switchElement] = true
                    Logger.log(indent: 0, string: "    \(switchElement): true")
                }
                else {
                    context.dictionary[switchElement] = false
                    Logger.log(indent: 0, string: "    \(switchElement): false")
                }
            }

            if !switches.isEmpty {
                Logger.log(indent: 0, string: "    --------------------------")
            }

            try checkTemplateCombination(template: template, context: context)
        }
    }
}

private extension Validator {
    /// Check particular template combination of enabled switches
    func checkTemplateCombination(template: Template, context: Context) throws {
        let validationFolder = try Folder(path: context.stringValue(.validatePath))

        let modifiedContext = Context(fromContext: context)
        modifiedContext[.generatePath] = modifiedContext[.validatePath]

        try generator.generate(
            context: modifiedContext,
            template: "SingleViewApp",
            deleteGenerate: true
        )

        let outputFolder = try validationFolder.subfolder(named: "Template")

        try generator.generate(
            context: modifiedContext,
            template: template,
            deleteGenerate: false
        )

        Logger.log(indent: 0, string: "    🗳 generating xcode project")
        // Create Xcodeproj
        let xcodegenOutput = shell("cd \"\(validationFolder.path)\";/usr/local/bin/xcodegen generate > /dev/null 2>&1")
        if xcodegenOutput.contains("error") {
            Logger.log(indent: 0, string: xcodegenOutput)
        }

        // Instal Cocoapods if needed
        if outputFolder.containsFile(named: "Podfile") {
            Logger.log(indent: 0, string: "    📦 installing pods")

            let podfile = try outputFolder.file(named: "Podfile")
            try podfile.move(to: validationFolder)

            let podsOutput = shell("cd \"\(validationFolder.path)\";export LANG=en_US.UTF-8;/usr/local/bin/pod install")
            if podsOutput.lowercased().contains("error") {
                Logger.log(indent: 0, string: podsOutput)
            }

            Logger.log(indent: 0, string: "    🕓 building workspace")
            // Build workspace
            let xcodebuildOutput = shell(
                "/usr/bin/xcodebuild -workspace \(validationFolder.path)/Template.xcworkspace/ " +
                    "-scheme Template -destination 'platform=iOS Simulator,name=iPhone 11,OS=13.5' build 2>&1")
            if xcodebuildOutput.contains("BUILD FAILED") {
                Logger.log(indent: 0, string: xcodebuildOutput)
            }
        }
        else {
            Logger.log(indent: 0, string: "    🕓 building project")

            // Build project
            let xcodebuildOutput = shell("/usr/bin/xcodebuild -project \(validationFolder.path)/Template.xcodeproj/ -scheme Template build 2>&1")
            if xcodebuildOutput.contains("BUILD FAILED") {
                Logger.log(indent: 0, string: xcodebuildOutput)
            }
        }

        Logger.log(indent: 0, string: "    🟢 Press enter to continue...", terminator: "")
        _ = readLine()
    }

    /// Default context used for template validation
    func defaultContext() -> Context {
        let context = Context(          // TODO: check, maybe obsolete
            dictionary: [
                "name": "test",
                "Name": "Test",

                "author": "Daniel Cech",
                "projectName": "Template",
                "copyright": "Copyright © 2020 STRV. All rights reserved.",

                "newTableViewCells": ["textField"],
                "tableContentFromAPI": false,

                "whiteCellSelection": true
            ]
        )

        context.updateContextWithAutogeneratedValues()
        try? context.setupScriptPaths()

        return context
    }
}
