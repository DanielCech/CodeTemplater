//
//  generator.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Files
import Foundation
import PathKit
import ScriptToolkit
import Stencil

class Generator {
    /// Dependencies
    private var reviewer: Reviewer
    private var templates: Templates

    init(templates: Templates, reviewer: Reviewer) {
        self.templates = templates
        self.reviewer = reviewer
    }

    var processedFiles = [ProcessedFile]()

    /// Generate code using template with context in json file
    func generateCode(context: Context) throws {
        let template = context.stringValue(.template)

        try generate(
            context: context,
            template: template,
            deleteGenerate: true
        )
    }
    
    /// Generate code using particular template
    func generate(
        context: Context,
        template: Template,
        deleteGenerate: Bool = true
    ) throws {
        try generateTemplate(template: template, context: context, deleteGenerate: deleteGenerate)

        // Apply swift format on generated code
        shell("/usr/local/bin/swiftformat \"\(context.stringValue(.scriptPath))\" > /dev/null 2>&1")

        try reviewer.review(processedFiles: processedFiles, context: context)
    }
}

private extension Generator {
    /// Generation of particular template
    func generateTemplate(
        template: Template,
        context: Context,
        deleteGenerate: Bool = true
    ) throws {
        
        let (templateCategory, templateName) = templates.templateParts(for: template)
        let templateInfo = try templates.templateInfo(for: template, context: context)
        let templateFolder = try Folder(path: context.stringValue(.templatePath)).subfolder(at: templateCategory).subfolder(at: templateName)

        // Delete contents of Generate folder
        let generatedFolder = try Folder(path: context.stringValue(.generatePath))
        if deleteGenerate {
            try generatedFolder.empty(includingHidden: true)
        }

        let projectFolder = try Folder(path: context.stringValue(.projectPath))

        try traverse(
            paths: ProcessedPaths(
                templatePath: templateFolder.path,
                middlePath: generatedFolder.path,
                projectPath: projectFolder.path
            ),
            templateInfo: templateInfo,
            context: context
        )
        
        // Generate also template dependencies
        try generateTemplateDependencies(templateInfo: templateInfo, context: context)
    }

    /// Generation of template dependencies
    func generateTemplateDependencies(
        templateInfo: TemplateInfo,
        context: Context
    ) throws {
        // Generate also template dependencies
        for dependency in templateInfo.dependencies {
            var dependencyName = dependency

            // Conditional dependency syntax: "template:condition1,condition2,..."; true if any of conditions is true
            if dependency.contains(":") {
                let parts = dependency.split(separator: ":")
                if let firstPart = parts.first, let lastPart = parts.last {
                    dependencyName = String(firstPart)
                    let conditions = String(lastPart).split(separator: ",")
                    var overallValue = false
                    for condition in conditions {
                        if let conditionValue = context.dictionary[String(condition)] as? Bool, conditionValue {
                            overallValue = true
                            break
                        }
                    }

                    // Dependency has not fullfilled conditions
                    if !overallValue {
                        continue
                    }
                }
            }

            try generateTemplate(
                template: dependencyName,
                context: context,
                deleteGenerate: false
            )
        }
    }

    /// Recursive traverse thru template, generated and project folders
    func traverse(
        paths: ProcessedPaths,
        templateInfo: TemplateInfo,
        context: Context
    ) throws {
        log.debug("\ntemplatePath: \(paths.templatePath),\ngeneratePath: \(paths.middlePath),\nprojectPath: \(paths.projectPath)")

        let templateFolder = try Folder(path: paths.templatePath)
        let generatedFolder = try Folder(path: paths.middlePath)

        // Process files in folder
        for file in templateFolder.files {
            try traverseProcessFile(
                file: file,
                templateInfo: templateInfo,
                paths: paths,
                environment: environment,
                context: context
            )
        }

        // Process subfolders
        for folder in templateFolder.subfolders {
            try traverseProcessSubfolder(
                paths: ProcessedPaths(
                    templatePath: folder.path,
                    middlePath: generatedFolder.path,
                    projectPath: paths.projectPath
                ),
                templateInfo: templateInfo,
                context: context
            )
        }
    }

    /// Generation of file based on template
    func traverseProcessFile(
        file: File,
        templateInfo: TemplateInfo,
        paths: ProcessedPaths,
        environment: Environment,
        context: Context
    ) throws {
        if file.name.lowercased() == "template.json"
            || file.name.lowercased().starts(with: "screenshot")
            || file.name.lowercased().starts(with: "description") {
            return
        }

        let outputFileName = try file.name.generateName(context: context)

        let modifiedContext = Context(fromContext: context)
        modifiedContext[.fileName] = outputFileName

        let generatedFolder = try Folder(path: paths.middlePath)
        let templateFolder = try Folder(path: paths.templatePath)

        let templateFile = paths.templatePath.appendingPathComponent(path: file.name)
        let generatedFile = paths.middlePath.appendingPathComponent(path: outputFileName)
        var projectFile = paths.projectPath.appendingPathComponent(path: outputFileName)

        // TODO: preferOriginalLocation implementation
        if templateInfo.preferOriginalLocation.contains(file.name) {
            let projectFolder = try Folder(path: context.stringValue(.projectPath))
            if let foundProjectFile = projectFolder.findFirstFile(name: outputFileName) {
                projectFile = foundProjectFile.path
            }
        }

        // Directly copy binary file
        guard var fileString = try? file.readAsString() else {
            let copiedFile = try file.copy(to: generatedFolder)
            try copiedFile.rename(to: outputFileName)
            return
        }

        let outputFile = try generatedFolder.createFile(named: outputFileName)

        var rendered: String
        do {
            // Stencil expressions {% for %} needs to be placed at the end of last line to prevent extra linespaces in generated code
            let matches = try fileString.regExpStringMatches(lineRegExp: #"\n^\w*\{% for .*%\}$"#)

            for match in matches {
                fileString = fileString.replacingOccurrences(of: match, with: " " + match.suffix(match.count - 1))
            }

            rendered = try environment.renderTemplate(string: fileString, context: modifiedContext.dictionary)
        }
        catch {
            throw CodeTemplaterError.stencilTemplateError(message: "\(templateFolder.path): \(file.name): \(error.localizedDescription)")
        }

        try outputFile.write(rendered)

        processedFiles.append(
            ProcessedFile(
                templateFile: templateFile,
                middleFile: generatedFile,
                projectFile: projectFile
            )
        )
    }

    /// Generate also nested subfolders
    func traverseProcessSubfolder(
        paths: ProcessedPaths,
        templateInfo: TemplateInfo,
        context: Context
    ) throws {
        var baseGeneratePath: String
        var baseProjectPath: String

        let templateFolder = try Folder(path: paths.templatePath)
        let generatedFolder = try Folder(path: paths.middlePath)
        
        switch LocationType(rawValue: templateFolder.name) {
        case .project:
            try traverse(
                paths: ProcessedPaths(
                    templatePath: paths.templatePath,
                    middlePath: paths.middlePath,
                    projectPath: context.stringValue(.projectPath)
                ),
                templateInfo: templateInfo,
                context: context
            )

        case .sources:
            baseGeneratePath = try generatedFolder.createSubfolder(at: context.stringValue(.sourcesPath).lastPathComponent).path
            baseProjectPath = context.stringValue(.sourcesPath)

            try traverse(
                paths: ProcessedPaths(
                    templatePath: paths.templatePath,
                    middlePath: baseGeneratePath,
                    projectPath: baseProjectPath
                ),
                templateInfo: templateInfo,
                context: context
            )

        case .location:
            let locationPath = context.stringValue(.locationPath)
            let projectPath = context.stringValue(.projectPath)
            
            guard locationPath.hasPrefix(projectPath) else {
                throw CodeTemplaterError.dataInconsistency(message: "locationPath should have project path as its prefix.")
            }
            
            
            let subPath = String(locationPath.suffix(locationPath.count - projectPath.count))

            if subPath.isEmpty {
                baseGeneratePath = paths.middlePath
            }
            else {
                baseGeneratePath = try generatedFolder.createSubfolder(at: subPath).path
            }

            baseProjectPath = context.stringValue(.locationPath)

            try traverse(
                paths: ProcessedPaths(
                    templatePath: paths.templatePath,
                    middlePath: baseGeneratePath,
                    projectPath: baseProjectPath
                ),
                templateInfo: templateInfo,
                context: context
            )

        default:
            let outputFolder = try templateFolder.name.generateName(context: context)
            let generatedSubFolder = try generatedFolder.createSubfolder(at: outputFolder)

            try traverse(
                paths: ProcessedPaths(
                    templatePath: paths.templatePath,
                    middlePath: generatedSubFolder.path,
                    projectPath: paths.projectPath.appendingPathComponent(path: outputFolder)
                ),
                templateInfo: templateInfo,
                context: context
            )
        }
    }
}
