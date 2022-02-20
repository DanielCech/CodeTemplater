//
//  ParameterProcessor.swift
//  CodeTemplater
//
//  Created by Daniel Cech on 24/07/2020.
//

import Files
import Foundation
import Moderator
import ScriptToolkit

/// The object for accessing and loading  the context
final class ParameterProcessor {
    // Dependencies
    var templates: Templates
    var installer: Installer

    var parameters = [Parameter]()
    let defaultParameterNames = DefaultBoolParameter.allCases.map { $0.rawValue } + DefaultStringParameter.allCases.map { $0.rawValue } + DefaultStringArrayParameter.allCases.map { $0.rawValue }

    // Shell parameters
    private var boolParameters = [String: FutureValue<Bool>]()
    private var stringParameters = [String: FutureValue<String?>]()
    private var stringArrayParameters = [String: FutureValue<String?>]()

    // swiftlint:disable implicitly_unwrapped_optional
    private var help: FutureValue<Bool>!
    private var install: FutureValue<Bool>!
    private var moderator: Moderator!
    // swiftlint:enable implicitly_unwrapped_optional

    private var possibleTemplates = [ParameterValue]()

    lazy var defaultParametersArray: [Parameter] = [
        // Generate/Prepare mode
        BoolParameter(
            name: "inPlace",
            description: "Generate: the template into the project to proper location. Prepare: use real location of files in project for template preparation.",
            defaultValue: false,
            mandatory: false,
            alwaysAsk: false
        ),
        BoolParameter(
            name: "noSkip",
            description: "Disable skipping of comparison using the merge tool if content is the same.",
            defaultValue: true,
            mandatory: false
        ),
        
        // Script setup
        StringParameter(
            name: "mode",
            description: "Current operation mode - code generation (generate), updating templates (update), template validation (validate) and preparation (prepare)",
            defaultValue: "generate",
            possibleValues: [.string("generate"), .string("update"), .string("validate"), .string("prepare")],
            alwaysAsk: false
        ),
        StringParameter(
            name: "reviewMode",
            description: "Template generator/preparator result review mode",
            defaultValue: "none",
            possibleValues: [.string("none"), .string("individual"), .string("overall")],
            alwaysAsk: false
        ),

        // Template parameters
        StringParameter(
            name: "template",
            description: "Code template name",
            possibleValues: possibleTemplates
        ),
        StringParameter(
            name: "templateScript",
            description: "The name of template script to run",
            mandatory: false
        ),
        StringParameter(
            name: "context",
            description: "The path to the JSON file with context",
            mandatory: false
        ),
        StringParameter(
            name: "name",
            description: "The name of created item"
        ),
        StringParameter(
            name: "projectName",
            description: "Project name which is often used also as target name if targetName is not defined"
        ),
        StringParameter(
            name: "targetName",
            description: "The name of app target if it differs from projectName",
            mandatory: false
        ),
        StringParameter(
            name: "author",
            description: "The author of project, used in source file header"
        ),
        StringParameter(
            name: "copyright",
            description: "Copyright phrase used in file header"
        ),
        StringParameter(
            name: "description",
            description: "The short description of template and its usage",
            mandatory: false
        ),
        StringParameter(
            name: "status",
            description: "The current status of template in terms of validation. The possible values are: draft (template has not been validated), passing (template passed the validation), failing (templated didn't pass the validation)",
            possibleValues: [.string("draft"), .string("passing"), .string("failing")],
            mandatory: false
        ),
        StringParameter(
            name: "derivedFrom",
            description: "The templated which current templated is derived from",
            defaultValue: "<none>",
            mandatory: false
        ),

        // Auto-generated parameters
        StringParameter(
            name: "fileName",
            description: "The name of currently processed file - automatically generated",
            mandatory: false
        ),
        StringParameter(
            name: "date",
            description: "The current date - automatically generated"
        ),

        // Paths
        StringParameter(
            name: "scriptPath",
            description: "Location of 'templater' folder"
        ),
        StringParameter(
            name: "locationPath",
            description: "Location of souce code",
            mandatory: false
        ),
        StringParameter(
            name: "projectPath",
            description: "Location of the project",
            mandatory: false
        ),
        StringParameter(
            name: "sourcesPath",
            description: "Location of project source files - typically projectPath + projectName folder",
            mandatory: false
        ),
        StringParameter(
            name: "templatePath",
            description: "Location of folder for templates - Templates"
        ),
        StringParameter(
            name: "generatePath",
            description: "Location of folder for generation - Generate"
        ),
        StringParameter(
            name: "validatePath",
            description: "Location of folder for validation - Validate"
        ),
        StringParameter(
            name: "preparePath",
            description: "Location of folder for preparation - Prepare"
        ),

        // Template preparation
        StringParameter(
            name: "deriveFromTemplate",
            description: "The name of template as origin for template preparation",
            defaultValue: "<none>",
            possibleValues: [.string("<none>")] + possibleTemplates,
            mandatory: false
        ),
        StringArrayParameter(
            name: "projectFiles",
            description: "The set of files for template preparation",
            mandatory: false
        )
    ]

    init(templates: Templates, installer: Installer) {
        self.templates = templates
        self.installer = installer
    }

    func getPossibleTemplates(context: Context) throws {
        let templateDict = try templates.templateTypes(context: context)
        possibleTemplates = templateDict.keys.map { .string($0) }
    }

    /// Setup of command line parameters parsing
    func setupShellParameters() {
        moderator = Moderator(description: "Generates a swift app components from templates")
        moderator.usageFormText = "codeTemplate <params>"

        for parameter in parameters {
            switch parameter.type {
            case .bool:
                boolParameters[parameter.name] = moderator.add(.option(parameter.name, description: parameter.description))
            case .string:
                stringParameters[parameter.name] = moderator.add(Argument<String?>
                    .optionWithValue(parameter.name, name: parameter.name, description: parameter.description))
            case .stringArray:
                stringArrayParameters[parameter.name] = moderator.add(Argument<String?>
                    .optionWithValue(parameter.name, name: parameter.name, description: parameter.description))
            }
        }

        help = moderator.add(.option("h", "help", description: "Show this documentation about available parameters"))
    }

    /// Parse command line parameteres by their type
    func parseShellParameters(context: Context, handleUnknownParameters: Bool = true) throws {
        if handleUnknownParameters {
            try moderator.parse()
        }
        else {
            try? moderator.parse()
        }

        if let contextFileValue = stringParameters["context"], let contextFile = contextFileValue.value {
            try context.applyContext(fromFile: contextFile)
        }

        // Overwrite context with command line parameters
        for parameterName in boolParameters.keys {
            if let commandLineValue = boolParameters[parameterName]?.value {
                context.dictionary[parameterName] = commandLineValue
            }

            // applyDefaultParameterValueIfNeeded(parameterName: parameterName, type: .bool, context: context)
        }

        for parameterName in stringParameters.keys {
            if let commandLineValue = stringParameters[parameterName]?.value {
                context.dictionary[parameterName] = commandLineValue
            }

            // applyDefaultParameterValueIfNeeded(parameterName: parameterName, type: .string, context: context)
        }

        for parameterName in stringArrayParameters.keys {
            if let commandLineValue = stringArrayParameters[parameterName]?.value {
                let separatedValues = commandLineValue.splittedBySpaces()
                context.dictionary[parameterName] = separatedValues
            }
            
//            if let commandLineValue = stringArrayParameters[parameterName]?.value, !commandLineValue.isEmpty {
//                // Weird behavior of command line parser workaround
//                if commandLineValue == ["true"] {
//                    context.dictionary[parameterName] = nil
//                }
//                else {
//                    context.dictionary[parameterName] = commandLineValue
//                }
//            }

            // applyDefaultParameterValueIfNeeded(parameterName: parameterName, type: .stringArray, context: context)
        }
    }

    /// Use default parameter value if needed
    func applyDefaultParameterValueIfNeeded(parameterName: String, type: ParameterType, context: Context) {
        // If value is missing, use default value if defined
        if context.dictionary[parameterName] == nil {
            if let parameter = getParameter(name: parameterName), parameter.type == type {
                switch parameter.defaultValue {
                case .none:
                    break
                case let .bool(value):
                    context.dictionary[parameterName] = value
                case let .string(value):
                    context.dictionary[parameterName] = value
                case let .stringArray(value):
                    context.dictionary[parameterName] = value
                }
            }
        }
    }

    /// Help hint
    func processSpecialParameters() throws {
        if help.value {
            Logger.log(indent: 0, string: moderator.usagetext)
            exit(0)
        }
    }

    /// Use default parameters only
    func resetWithDefaultParameters() {
        parameters = defaultParametersArray
        log.debug(debugDescription())
    }

    /// Update the parameter list
    func appendParameterDefinitions(_ definitions: [Parameter]) throws {
        for definition in definitions {
            if let parameter = parameters.first(where: { $0.name == definition.name }) {
                if parameter.type != definition.type {
                    throw CodeTemplaterError.defaultParameterOverride(message: definition.name)
                }
                parameters.removeAll(where: { $0.name == definition.name })
            }

            if defaultParameterNames.contains(definition.name) {
                // TODO: check !!!
            }

            parameters.append(definition)
        }
    }

    /// Parameter definitions included in template.json
    func loadTemplateParameters(templateName: String, context: Context) throws {
        let dependencyList = try templates.templateWithDependencies(templateName: templateName, context: context)
        var newParameters = [Parameter]()

        for dependency in dependencyList {
            let dependencyTemplate = try templates.templateInfo(for: dependency, context: context)

            newParameters.append(contentsOf: dependencyTemplate.parameters)
        }

        try appendParameterDefinitions(newParameters)

        log.debug(debugDescription())
    }

    /// Parameter definitions included in template.json
    func loadTemplateScriptParameters(templateScriptName: String, context: Context) throws {
        let dependencyList = try templates.templateWithDependencies(templateName: templateScriptName, context: context)
        var newParameters = [Parameter]()

        for dependency in dependencyList {
            let dependencyTemplate = try templates.templateInfo(for: dependency, context: context)

            newParameters.append(contentsOf: dependencyTemplate.parameters)
        }

        try appendParameterDefinitions(newParameters)

        log.debug(debugDescription())
    }

    /// Asking for particular parameter
    func getParameter(name: String) -> Parameter? {
        parameters.first(where: { $0.name == name })
    }

    /// Some modifications of setup before asking for new params
    func setupParametersBeforeAsking(context: Context) {
        // If location path is defined, make projectPath mandatory and set review mode to "individual"
        if context.inPlace {
            for index in 0 ... parameters.count - 1 {
                if parameters[index].name == "projectPath" {
                    parameters[index].mandatory = true
                    break
                }
            }

            context[.reviewMode] = "individual"
        }
    }

    /// Asking for missing parameters
    func askForMissingParameters(context: Context) {
        var missingParameterNames = [String]()

        for parameter in parameters {
            if context.dictionary[parameter.name] == nil, parameter.mandatory {
                missingParameterNames.append(parameter.name)
            }
        }

        log.debug("missingParameterNames: \(missingParameterNames)")

        for parameterName in missingParameterNames {
            if let parameter = getParameter(name: parameterName) {
                switch parameter.type {
                case .bool:
                    _ = context.boolValue(parameterName)
                case .string:
                    // Asking for template in prepare mode is specific - the template does not exist
                    if (context.stringValue(.mode) == ProgramMode.prepare.rawValue) && (parameter.name == "template") {
                        Logger.log(indent: 0, string: "🧩 Missing parameter '\(parameterName)': \(parameter.description).")
                        Logger.log(indent: 0, string: "❔ Enter '\(parameterName)': ", terminator: "")
                        if let input = readLine() {
                            Logger.log(indent: 0, string: "")
                            context[.template] = input
                        }
                    }
                    else {
                        _ = context.stringValue(parameterName)
                    }
                
                case .stringArray:
                    _ = context.stringArrayValue(parameterName)
                }
            }
        }
    }
}

// MARK: - Debug print

extension ParameterProcessor {
    func debugDescription() -> String {
        let parametersDescription = dumpString(parameters)
        return "parameters: \(parametersDescription)"
    }
}
