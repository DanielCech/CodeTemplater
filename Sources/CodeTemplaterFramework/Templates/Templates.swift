//
//  Template.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Files
import Foundation
import ScriptToolkit

public typealias Template = String

/// Code template management
final class Templates {
    /// Internal representation of templates
    private var templateTypesDict: [Template: TemplateInfo] = [:]

    /// Internal representation of template derivations
    private var templateDerivationsDict: [Template: [Template]] = [:]

    /// Loads templates from folder structure in Templates dir and loads their json
    @discardableResult func templateTypes(context: Context) throws -> [Template: TemplateInfo] {
        if !templateTypesDict.isEmpty {
            return templateTypesDict
        }

        Logger.log(indent: 0, string: "💡 Loading templates")

        templateTypesDict = [Template: TemplateInfo]()

        let templatesFolder = try Folder(path: context.stringValue(.templatePath))
        
        try processTemplateFolder(templatesFolder, path: "")

        // TODO: rewrite and make recursive; get rid of template category
        
//        for categoryFolder in templatesFolder.subfolders {
//            for templateFolder in categoryFolder.subfolders {
//                let infoFilePath = templateFolder.path.appendingPathComponent(path: "template.json")
//                guard FileManager.default.fileExists(atPath: infoFilePath) else {
//                    throw CodeTemplaterError.fileNotFound(message: infoFilePath)
//                }
//
//                let info = try templateInfo(infoFilePath: infoFilePath)
//
//                types[categoryFolder.name+"@"+templateFolder.name] = info
//
//                // TemplateInfo(category: categoryFolder.name, templateInfo: templateInfo)
//            }
//        }

        return templateTypesDict
    }
    
    func processTemplateFolder(_ folder: Folder, path: String) throws {
        let infoFilePath = folder.path.appendingPathComponent(path: "template.json")
        if FileManager.default.fileExists(atPath: infoFilePath) {
            let info = try templateInfo(infoFilePath: infoFilePath)

            templateTypesDict[path] = info
            return
        }
        
        for subfolder in folder.subfolders {
            try processTemplateFolder(subfolder, path: path.appendingPathComponent(path: subfolder.name))
        }
    }
    
    /// Returns template info structure
    func templateInfo(for template: Template, context: Context) throws -> TemplateInfo {
        if let templateInfo = try templateTypes(context: context)[template] {
            return templateInfo
        }
        else {
            throw CodeTemplaterError.argumentError(message: "template '\(template)' does not exist")
        }
    }

    func templateWithDependencies(templateName: String, context: Context) throws -> [String] {
        var templateNames = [String]()
        templateNames.append(templateName)

        let template = try templateInfo(for: templateName, context: context)

        for dependency in template.dependencies {            
            var dependencyName = dependency

            // Conditional dependency syntax: "template <=> condition1 && (condition2 || condition3)"; the logical expression
            if dependency.contains(" <=> ") {
                let parts = dependency.components(separatedBy: " <=> ")
                if let firstPart = parts.first, let lastPart = parts.last, parts.count == 2 {
                    dependencyName = String(firstPart)
                    var condition = String(lastPart)
                    
                    // Bool values substitutions
                    for parameterName in context.boolParameterNames() {
                        condition = condition.replacingOccurrences(of: parameterName, with: String(context.boolValue(parameterName)))
                    }
                    
                    var validExpression = true
                    for part in condition.split(separator: " ") {
                        if !FileConstants.validExpressions.contains(String(part)) {
                            Logger.log(indent: 0, string: "⚠️ The dependency expression \(condition) is not valid.")
                            validExpression = false
                            break
                        }
                    }
                    
                    if !validExpression {
                        continue
                    }
                    
                    let expression = NSExpression(format: condition)
                        
                    if let result = expression.expressionValue(with: nil, context: nil) as? Bool, !result {
                        continue
                    }
                    else {
                        continue
                    }
                }
            }
            
            // Generate template only if expression is true
            templateNames.append(contentsOf: try templateWithDependencies(templateName: dependencyName, context: context))
        }

        return templateNames
    }

    /// Returns template category
//    func templateCategory(for template: Template) throws -> String {
//        if let templateInfo = try templateTypes()[template] {
//            return templateInfo.category
//        } else {
//            throw ScriptError.argumentError(message: "template '\(template)' does not exist")
//        }
//    }

    /// Loads template derivations from json
//    func templateDerivations() throws -> [Template: [Template]] {
//        if !templateDerivationsDict.isEmpty {
//            return templateDerivationsDict
//        }
//
//        let derivationsFilePath = mainContext.stringValue(.templatePath).appendingPathComponent(path: "derivations.json")
//
//        let derivationsFile = try File(path: derivationsFilePath)
//        let derivationsString = try derivationsFile.readAsString(encodedAs: .utf8)
//        let derivationsData = Data(derivationsString.utf8)
//
//        // make sure this JSON is in the format we expect
//        guard let derivations = try JSONSerialization.jsonObject(with: derivationsData, options: []) as? [Template: [Template]] else {
//            throw ScriptError.generalError(message: "Deserialization error")
//        }
//
//        templateDerivationsDict = derivations
//
//        return derivations
//    }

//    func updateTemplateDerivations(template: Template, deriveFromTemplate: Template) throws {
//        if templateDerivationsDict.isEmpty {
//            _ = try templateDerivations()
//        }
//
//        if var array = templateDerivationsDict[deriveFromTemplate] {
//            array.append(template)
//            templateDerivationsDict[deriveFromTemplate] = array
//        } else {
//            templateDerivationsDict[deriveFromTemplate] = [template]
//        }
//
//        let encoder = JSONEncoder()
//        if let jsonData = try? encoder.encode(templateDerivationsDict) {
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                Logger.log(indent: 0, string: jsonString)
//
//                let derivationsFilePath = mainContext.stringValue(.templatePath).appendingPathComponent(path: "derivations.json")
//                let derivationsFile = try File(path: derivationsFilePath)
//
//                try derivationsFile.write(jsonString, encoding: .utf8)
//            }
//        }
//    }
}

private extension Templates {
    /// Creates template info structure from json
    private func templateInfo(infoFilePath: String) throws -> TemplateInfo {
        let templateInfoFile = try File(path: infoFilePath)
        let templateInfoString = try templateInfoFile.readAsString(encodedAs: .utf8)
        let templateInfoData = Data(templateInfoString.utf8)

        do {
            // make sure this JSON is in the format we expect
            guard let info = try JSONSerialization.jsonObject(with: templateInfoData, options: []) as? [String: Any] else {
                throw CodeTemplaterError.generalError(message: "File \(infoFilePath) is not valid JSON.")
            }
            var parameters = [Parameter]()
            if let paramArray = info["parameters"] as? [[String: Any]] {
                for paramDict in paramArray {
                    if let type = paramDict["type"] as? String {
                        switch ValueType(rawValue: type) {
                        case .bool:
                            parameters.append(try BoolParameter(paramDict))
                        case .string:
                            parameters.append(try StringParameter(paramDict))
                        case .stringArray:
                            parameters.append(try StringArrayParameter(paramDict))
                        default:
                            break
                        }
                    }
                }
            }

            let templateInfo = TemplateInfo(
                description: (info["description"] as? String) ?? "",
                status: (info["status"] as? String) ?? TemplateStatus.draft.rawValue,
                dependencies: (info["dependencies"] as? [String]) ?? [],
                validationContext: Context(dictionary: (info["validationContext"] as? [String: Any]) ?? [:]),
                preferOriginalLocation: (info["preferOriginalLocation"] as? [String]) ?? [],
                parameters: parameters
            )

            return templateInfo
        }
        catch {
            throw CodeTemplaterError.generalError(message: "File \(infoFilePath) is not valid JSON.")
        }
    }
}

private enum FileConstants {
    static let validExpressions = ["true", "false", "&&", "||", "AND", "OR", ""]
}
