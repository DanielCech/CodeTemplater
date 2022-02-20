//
//  Preparator.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Files
import Foundation
import PathKit
import ScriptToolkit
import Stencil

/// Extracts the source code into the code template
final class Preparator {
    var processedFiles = [ProcessedFile]()
    var dependencies: Dependencies = (typeDependencies: Set([]), frameworkDependencies: Set([]))

    /// Dependencies
    private var templates: Templates
    private var reviewer: Reviewer
    private var dependencyAnalyzer: DependencyAnalyzer

    init(templates: Templates, reviewer: Reviewer, dependencyAnalyzer: DependencyAnalyzer) {
        self.templates = templates
        self.reviewer = reviewer
        self.dependencyAnalyzer = dependencyAnalyzer
    }

    /// Prepares the code template
    func prepareTemplate(
        context: Context,
        deletePrepare: Bool = true
    ) throws {
        if context.optionalStringValue(.locationPath) != nil {
            context[.inPlace] = true
        }
        
        if context.inPlace {
            context[.reviewMode] = ReviewMode.individual.rawValue
        }
        
        try prepareTemplateCore(
            context: context,
            deletePrepare: deletePrepare
        )

        try reviewer.review(processedFiles: processedFiles, context: context)
    }
}

private extension Preparator {
    /// Generation of particular template
    func prepareTemplateCore(
        context: Context,
        deletePrepare: Bool = true
    ) throws {
        let template = context.stringValue(.template)
        let projectFiles = context.stringArrayValue(.projectFiles)
        let name = context.stringValue(.name)
        
        // Delete contents of Prepare folder
        try deletePrepareFolder(deletePrepare, context: context)

        try prepareTemplateFolder(
            template: template,
            context: context
        )

        if context.stringValue(.deriveFromTemplate) == .none {
            context[.deriveFromTemplate] = nil
        }
        
        try createTemplateJSON(
            template: template,
            deriveFromTemplate: context.optionalStringValue(.deriveFromTemplate),
            context: context
            )

        for projectFilePath in projectFiles {
            try prepareTemplate(
                context: context,
                projectFilePath: projectFilePath,
                template: template,
                name: name
            )
        }

        Logger.log(indent: 0, string: "\n⚙️ Type dependencies: \(Array(dependencies.typeDependencies))")
        Logger.log(indent: 0, string: "\n⚙️ Framework dependencies: \(Array(dependencies.frameworkDependencies))\n")

        Logger.log(indent: 0, string: "🔎 Searching for type dependencies definitions:")
        let result = try dependencyAnalyzer.findDefinitions(forTypeDependencies: dependencies.typeDependencies, context: context)
        Logger.log(indent: 0, string: "🔎 Searching done\n")

        Logger.log(indent: 0, string: "⚠️ Unprocessed dependencies:")
        let list = result.values
        Logger.log(indent: 0, string: list.description)

        try dependencyAnalyzer.createPodfile(forFrameworkDependencies: dependencies.frameworkDependencies)
    }

    /// Template preparation for particular file
    func prepareTemplate(
        context: Context,
        projectFilePath: String,
        template: Template,
        name: String
    ) throws {
        let templatePath = context.stringValue(.templatePath).appendingPathComponent(path: template)
        let preparePath = context.stringValue(.preparePath)

        let projectFile = try File(path: projectFilePath)

        Logger.log(indent: 0, string: "\(projectFile.name):")

        // Prepare target folder structure
        var templateDestination: LocationType
        var projectSubPath = projectFilePath.deletingLastPathComponent.withoutSlash()

        if projectFilePath.deletingLastPathComponent.lowercased().withoutSlash() == context.stringValue(.projectPath).lowercased().withoutSlash() {
            templateDestination = .project
            projectSubPath = String(projectSubPath.suffix(projectSubPath.count - context.stringValue(.projectPath).count))
        }
        else if projectFilePath.lowercased().withoutSlash().starts(with: context.stringValue(.locationPath).lowercased().withoutSlash()) {
            templateDestination = .location
            projectSubPath = String(projectSubPath.suffix(projectSubPath.count - context.stringValue(.locationPath).count))
        }
        else if projectFilePath.lowercased().withoutSlash().starts(with: context.stringValue(.sourcesPath).lowercased().withoutSlash()) {
            templateDestination = .sources
            projectSubPath = String(projectSubPath.suffix(projectSubPath.count - context.stringValue(.sourcesPath).count))
        }
        else {
            throw CodeTemplaterError.invalidProjectFilePath(message: projectFilePath)
        }

        let templateSubPath = templatePath.appendingPathComponent(path: templateDestination.rawValue)
        let prepareSubPath = preparePath.appendingPathComponent(path: templateDestination.rawValue)
        try? FileManager.default.createDirectory(atPath: prepareSubPath, withIntermediateDirectories: true, attributes: nil)

//        if !projectSubPath.isEmpty {
        let templateDestinationPath = templateSubPath.appendingPathComponent(path: projectSubPath)
        let prepareDestinationPath = prepareSubPath.appendingPathComponent(path: projectSubPath)
        try? FileManager.default.createDirectory(atPath: prepareDestinationPath, withIntermediateDirectories: true, attributes: nil)

        let prepareDestinationFolder = try Folder(path: prepareDestinationPath)
        let prepareCopiedFile = try projectFile.copy(to: prepareDestinationFolder)

        let fileDependencies = try dependencyAnalyzer.analyzeFileDependencies(of: prepareCopiedFile)

        dependencies.typeDependencies = dependencies.typeDependencies.union(fileDependencies.typeDependencies)
        dependencies.frameworkDependencies = dependencies.typeDependencies.union(fileDependencies.frameworkDependencies)

        try prepareTemplate(for: prepareCopiedFile, context: context)

        let preparedFileNewName = prepareCopiedFile.name.prepareName(name: name)
        try prepareCopiedFile.rename(to: preparedFileNewName, keepExtension: false)

        let templateFile = templateDestinationPath.appendingPathComponent(path: preparedFileNewName)
        let preparedFile = prepareDestinationPath.appendingPathComponent(path: preparedFileNewName)

        processedFiles.append(
            ProcessedFile(
                templateFile: templateFile,
                middleFile: preparedFile,
                projectFile: projectFilePath
            )
        )

//        let copiedFile = try file.copy(to: generatedFolder)
//        try copiedFile.rename(to: outputFileName)
//            continue
//        }
    }

    // TODO: fix !!!

//    /// Recursive traverse thru template, generated and project folders
//    func traverse(
//        templatePath: String,
//        generatePath: String,
//        projectPath: String,
//        context: Context,
//        templateInfo: TemplateInfo,
//        validationMode: Bool = false
//    ) throws {
//        let templateFolder = try Folder(path: templatePath)
//        let generatedFolder = try Folder(path: generatePath)
//
//        let environment = stencilEnvironment(templateFolder: templateFolder)
//
//        // Process files in folder
//        for file in templateFolder.files {
//            try traverseProcessFile(
//                context: context,
//                file: file,
//                templateInfo: templateInfo,
//                templatePath: templatePath,
//                generatePath: generatePath,
//                projectPath: projectPath,
//                environment: environment
//            )
//        }
//
//        // Process subfolders
//        for folder in templateFolder.subfolders {
//            try traverseProcessSubfolder(
//                context: context,
//                folder: folder,
//                templateInfo: templateInfo,
//                validationMode: validationMode,
//                generatedFolder: generatedFolder,
//                projectPath: projectPath
//            )
//        }
//    }
//
//    func traverseProcessFile(
//        context: Context,
//        file: File,
//        templateInfo: TemplateInfo,
//        templatePath: String,
//        generatePath: String,
//        projectPath: String,
//        environment: Environment
//    ) throws {
//        if file.name.lowercased() == "template.json"
//            || file.name.lowercased().starts(with: "screenshot")
//            || file.name.lowercased().starts(with: "description") {
//            return
//        }
//
//        let outputFileName = file.name.generateName(context: context)
//
//        let modifiedContext = Context(fromContext: context)
//        modifiedContext[.fileName] = outputFileName
//
//        let generatedFolder = try Folder(path: generatePath)
//        let templateFolder = try Folder(path: templatePath)
//
//        let templateFile = templatePath.appendingPathComponent(path: file.name)
//        let generatedFile = generatePath.appendingPathComponent(path: outputFileName)
//        var projectFile = projectPath.appendingPathComponent(path: outputFileName)
//
//        // TODO: preferOriginalLocation implementation
//        if templateInfo.preferOriginalLocation.contains(file.name) {
//            let projectFolder = try Folder(path: context.stringValue(.projectPath))
//            if let foundProjectFile = projectFolder.findFirstFile(name: outputFileName) {
//                projectFile = foundProjectFile.path
//            }
//        }
//
//        // Directly copy binary file
//        guard var fileString = try? file.readAsString() else {
//            let copiedFile = try file.copy(to: generatedFolder)
//            try copiedFile.rename(to: outputFileName)
//            return
//        }
//
//        let outputFile = try generatedFolder.createFile(named: outputFileName)
//
//        var rendered: String
//        do {
//            // Stencil expressions {% for %} needs to be placed at the end of last line to prevent extra linespaces in generated code
//            let matches = try! fileString.regExpStringMatches(lineRegExp: #"\n^\w*\{% for .*%\}$"#)
//
//            for match in matches {
//                fileString = fileString.replacingOccurrences(of: match, with: " " + match.suffix(match.count - 1))
//            }
//
//            rendered = try environment.renderTemplate(string: fileString, context: modifiedContext.dictionary)
//        } catch {
//            throw CodeTemplaterError.stencilTemplateError(message: "\(templateFolder.path): \(file.name): \(error.localizedDescription)")
//        }
//
//        try outputFile.write(rendered)
//
//        processedFiles.append((templateFile: templateFile, generatedFile: generatedFile, projectFile: projectFile))
//    }
//
//    func traverseProcessSubfolder(
//        context: Context,
//        folder: Folder,
//        templateInfo: TemplateInfo,
//        validationMode: Bool,
//        generatedFolder: Folder,
//        projectPath: String
//    ) throws {
//        var baseGeneratePath: String
//        var baseProjectPath: String
//
//        switch folder.name {
//        case "_project":
//            try traverse(
//                templatePath: folder.path,
//                generatePath: generatedFolder.path,
//                projectPath: context.stringValue(.projectPath),
//                context: context,
//                templateInfo: templateInfo
//            )
//
//        case "_sources":
//            if validationMode {
//                baseGeneratePath = generatedFolder.path
//            } else {
//                baseGeneratePath = try generatedFolder.createSubfolder(at: context.stringValue(.sourcesPath).lastPathComponent).path
//            }
//
//            baseProjectPath = context.stringValue(.sourcesPath)
//
//            try traverse(
//                templatePath: folder.path,
//                generatePath: baseGeneratePath,
//                projectPath: baseProjectPath,
//                context: context,
//                templateInfo: templateInfo
//            )
//
//        case "_location":
//            let subPath = String(context.stringValue(.locationPath).suffix(context.stringValue(.locationPath).count - context.stringValue(.projectPath).count))
//
//            if validationMode {
//                baseGeneratePath = generatedFolder.path
//            } else {
//                baseGeneratePath = try generatedFolder.createSubfolder(at: subPath).path
//            }
//
//            baseProjectPath = context.stringValue(.locationPath)
//
//            try traverse(
//                templatePath: folder.path,
//                generatePath: baseGeneratePath,
//                projectPath: baseProjectPath,
//                context: context,
//                templateInfo: templateInfo
//            )
//
//        default:
//            let outputFolder = folder.name.generateName(context: context)
//            let generatedSubFolder = try generatedFolder.createSubfolder(at: outputFolder)
//
//            try traverse(
//                templatePath: folder.path,
//                generatePath: generatedSubFolder.path,
//                projectPath: projectPath.appendingPathComponent(path: outputFolder),
//                context: context,
//                templateInfo: templateInfo
//            )
//        }
//    }
}

private extension Preparator {
    /// Create template.json using template derivation
    func createTemplateJSON(
        template: Template,
        deriveFromTemplate parentTemplate: Template?,
        context: Context
    ) throws {
        // If deriveFromTemplate is specified, copy template.json from parent template
        if let unwrappedParentTemplate = parentTemplate {
            let parentTemplatePath = context.stringValue(.templatePath)
                .appendingPathComponent(path: unwrappedParentTemplate)

            let currentTemplatePath = context.stringValue(.templatePath)
                .appendingPathComponent(path: template)

            let parentTemplateFolder = try Folder(path: parentTemplatePath)
            let currentTemplareFolder = try Folder(path: currentTemplatePath)

            try deleteTemplateJSON(template: template, context: context)

            let parentTemplateJSON = try parentTemplateFolder.file(named: "template.json")
            try parentTemplateJSON.copy(to: currentTemplareFolder)
        }
        else {
            // Create default empty template.json
            try createEmptyTemplateJSON(
                template: template,
                context: context
            )
        } 
    }

    /// Creates empty JSON file with default content
    func createEmptyTemplateJSON(
        template: Template,
        context: Context
    ) throws {
        let json = """
        {
          "description": "",
          "status": "draft",
          "derivedFrom": null,
          "validationContext": {}
        }
        """

        let templateLocation = template.replacingOccurrences(of: "@", with: "/")
        let templatePath = context.stringValue(.templatePath)
            .appendingPathComponent(path: templateLocation)

        let templateFolder = try Folder(path: templatePath)

        if templateFolder.containsFile(named: "template.json") {
            return
        }

        let jsonFile = try templateFolder.createFile(named: "template.json")
        try jsonFile.write(json, encoding: .utf8)
    }

    /// Deletes template.json file of template
    func deleteTemplateJSON(template: Template, context: Context) throws {
        let templatePath = context.stringValue(.templatePath)
            .appendingPathComponent(path: template)

        let templateFolder = try Folder(path: templatePath)
        let templateFile = try templateFolder.file(named: "template.json")
        try templateFile.delete()
    }

    /// Prepares template for particular source code file
    func prepareTemplate(for file: File, context: Context) throws {
        let contents = try file.readAsString()
        var newContents = contents
        var comment = ""

        if file.extension?.lowercased() == "swift" {
            for line in contents.lines() {
                if line.starts(with: "//") {
                    comment += line + "\n"
                }
                else {
                    let newComment =
                        """
                        //
                        //  {{fileName}}
                        //  {{projectName}}
                        //
                        //  Created by {{author}} on {{date}}.
                        //  {{copyright}}
                        //

                        """
                    newContents = newContents.replacingOccurrences(of: comment, with: newComment)
                    break
                }
            }
        }
        else {
            newContents = contents
        }

        let sortedKeys = context.dictionary.keys.sorted()
        for key in sortedKeys {
            guard let value = context.dictionary[key] as? String else {
                continue
            }

            if stringParametersIgnoredDuringPreparation.contains(key) {
                continue
            }

            newContents = newContents.replacingOccurrences(of: value.decapitalized(), with: "{{\(key)|decapitalized}}")
            newContents = newContents.replacingOccurrences(of: value.capitalized(), with: "{{\(key)|capitalized}}")
        }

        // Generalize coordinator
        newContents = try newContents.stringByReplacingMatches(
            pattern: "var coordinator: (.*)Coordinating!",
            withTemplate: "var coordinator: {{coordinator}}Coordinating!"
        )

        try file.write(newContents)
    }

    /// Template folder creation
    func prepareTemplateFolder(template: Template, context: Context) throws {
        let templatePath = context.stringValue(.templatePath).appendingPathComponent(path: template)
        try? FileManager.default.createDirectory(atPath: templatePath, withIntermediateDirectories: true, attributes: nil)
        let templateFolder = try Folder(path: templatePath)

        Logger.log(indent: 0, string: "❔ Empty the template folder? [yN] ", terminator: "")
        if readLine() == "y" {
            try templateFolder.empty(includingHidden: true)
        }
        
        Logger.log(indent: 0, string: "")
    }
    
    /// Delete contents of Prepare folder and reset dependencies
    func deletePrepareFolder(_ deletePrepare: Bool, context: Context) throws {
        let prepareFolder = try Folder(path: context.stringValue(.preparePath))
        if deletePrepare {
            try prepareFolder.empty(includingHidden: true)

            // Reset dependencies
            dependencies = (typeDependencies: Set([]), frameworkDependencies: Set([]))
        }
    }
}
