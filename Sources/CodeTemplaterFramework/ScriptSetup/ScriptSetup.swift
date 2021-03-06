//
//  ScriptSetup.swift
//  CodeTemplaterr
//
//  Created by Daniel Cech on 09/09/2020.
//

import Foundation
import ScriptToolkit

final class ScriptSetup {
    /// Main functionality objects
    // swiftlint:disable implicitly_unwrapped_optional
    private var templates: Templates!
    private var installer: Installer!
    private var templateScripts: TemplateScripts!
    private var generator: Generator!
//    private var validator: Validator!
    private var preparator: Preparator!
    private var reviewer: Reviewer!
    private var dependencyAnalyzer: DependencyAnalyzer!
    // swiftlint:enable implicitly_unwrapped_optional

    init() {}

    /// Initial steps for proper script configuration
    func initializeContext() throws -> Context {
        let context = Context()
        try context.applyDefaultContext()
        try context.setupScriptPaths()
        context.updateContextWithAutogeneratedValues()

        return context
    }

    func process(context: Context) throws {
        templates = Templates()
        
        installer = Installer()
        
        parameterProcessor = ParameterProcessor(templates: templates, installer: installer)

        // Loading CodeTemplater.json in current folder

        // Load available templates from Templates folder
        try templates.templateTypes(context: context)

        // Load available template scripts from TemplateScripts folder
        templateScripts = TemplateScripts()
        try templateScripts.templateScripts(context: context)

        // Parsing of default command line parameters
        try parameterProcessor.getPossibleTemplates(context: context)
        parameterProcessor.resetWithDefaultParameters()
        parameterProcessor.setupShellParameters()
        try parameterProcessor.parseShellParameters(context: context, handleUnknownParameters: false)

        // Show help with parameter specification if needed
        try parameterProcessor.processSpecialParameters()

        if context.stringValue(.mode) == "generate" {
            let templateName = context.stringValue(.template)
            try parameterProcessor.loadTemplateParameters(templateName: templateName, context: context)
            parameterProcessor.setupShellParameters()
            try parameterProcessor.parseShellParameters(context: context)
        }

        askForMissingParameters(context: context)
    }

    func askForMissingParameters(context: Context) {
        parameterProcessor.setupParametersBeforeAsking(context: context)
        parameterProcessor.askForMissingParameters(context: context)
    }

    /// Initialization of componentes with simple dependency injection
    func initializeComponents() {
        reviewer = Reviewer()
        dependencyAnalyzer = DependencyAnalyzer()
        generator = Generator(templates: templates, reviewer: reviewer)
        preparator = Preparator(templates: templates, reviewer: reviewer, dependencyAnalyzer: dependencyAnalyzer)
    }

    /// Basic usage information
    func showUsageText() {
        Logger.log(indent: 0, string: "codeTemplate - Generates a swift app components from templates")
        Logger.log(indent: 0, string: "use argument `--help` for documentation\n")
    }
}

extension ScriptSetup {
    func generateCode(context: Context) throws {
        try context.setupProjectPaths()
        try generator.generateCode(context: context)
    }

//    func validate(context: Context) throws {
//        context[.projectPath] = context[.generatePath]
//        context[.locationPath] = context[.projectPath]?.appendingPathComponent(path: "Template")
//        context[.sourcesPath] = context[.locationPath]
//
//        if let unwrappedTemplate = context.optionalStringValue(.template) {
//            try validator.validate(template: unwrappedTemplate, context: context)
//        }
//        else {
//            // Validate all templates
//            try validator.validateTemplates(context: context)
//        }
//    }

    func prepareTemplate(context: Context) throws {
        try context.setupProjectPaths()
        try preparator.prepareTemplate(context: context)
    }
}
