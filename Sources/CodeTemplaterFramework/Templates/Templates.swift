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
public typealias TemplateParts = (category: String, name: String)

/// Code template management
class Templates {
//     let shared = Templates()

    /// Internal representation of templates
    private var templateTypesDict: [Template: TemplateInfo] = [:]

    /// Internal representation of template derivations
    private var templateDerivationsDict: [Template: [Template]] = [:]

    /// Loads templates from folder structure in Templates dir and loads their json
    @discardableResult func templateTypes(context: Context) throws -> [Template: TemplateInfo] {
        if !templateTypesDict.isEmpty {
            return templateTypesDict
        }

        print("💡 Loading templates\n")

        var types = [Template: TemplateInfo]()

        let templatesFolder = try Folder(path: context.stringValue(.templatePath))

        for categoryFolder in templatesFolder.subfolders {
            for templateFolder in categoryFolder.subfolders {
                let infoFilePath = templateFolder.path.appendingPathComponent(path: "template.json")
                guard FileManager.default.fileExists(atPath: infoFilePath) else {
                    throw CodeTemplaterError.fileNotFound(message: infoFilePath)
                }

                let info = try templateInfo(infoFilePath: infoFilePath, category: categoryFolder.name)

                types[categoryFolder.name+":"+templateFolder.name] = info

                // TemplateInfo(category: categoryFolder.name, templateInfo: templateInfo)
            }
        }

        templateTypesDict = types

        return types
    }

    /// Divides the template into template category and template name
    func templateParts(for template: Template) -> TemplateParts {
        let parts = template.split(separator: ":").map { String($0) }
        return (category: parts.first ?? "", name: parts.last ?? "")
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
        
        for subtemplate in template.dependencies {
            templateNames.append(contentsOf: try templateWithDependencies(templateName: subtemplate, context: context))
        }
        
        return templateNames
    }
}

private extension Templates {
    /// Creates template info structure from json
    private func templateInfo(infoFilePath: String, category: String) throws -> TemplateInfo {
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
                category: category,
                dependencies: (info["dependencies"] as? [String]) ?? [],
                completeness: (info["completeness"] as? Int) ?? 0,
                compilable: (info["compilable"] as? Bool) ?? true,
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
