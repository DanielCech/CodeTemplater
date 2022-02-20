//
//  TemplateScripts.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Files
import Foundation
import ScriptToolkit

public typealias TemplateScript = String

/// Code template management
final class TemplateScripts {
    /// Internal representation of templates
    private var templateScriptsDict: [TemplateScript: TemplateScriptInfo] = [:]

    /// Loads templates from folder structure in Templates dir and loads their json
    @discardableResult func templateScripts(context: Context) throws -> [TemplateScript: TemplateScriptInfo] {
        if !templateScriptsDict.isEmpty {
            return templateScriptsDict
        }

        Logger.log(indent: 0, string: "💡 Loading template scripts\n")

        var scripts = [TemplateScript: TemplateScriptInfo]()

        let templateScriptsFolder = try Folder(path: context.stringValue(.templateScriptPath))

        for templateScriptFolder in templateScriptsFolder.subfolders {
            let infoFilePath = templateScriptFolder.path.appendingPathComponent(path: "templateScript.json")
            guard FileManager.default.fileExists(atPath: infoFilePath) else {
                throw CodeTemplaterError.fileNotFound(message: infoFilePath)
            }

            let info = try templateScriptInfo(infoFilePath: infoFilePath)

            scripts[templateScriptFolder.name] = info

            // TemplateScriptInfo(category: categoryFolder.name, templateScriptInfo: templateScriptInfo)
        }

        templateScriptsDict = scripts

        return scripts
    }

    /// Returns template info structure
    func templateScriptInfo(for script: TemplateScript, context: Context) throws -> TemplateScriptInfo {
        if let templateScriptInfo = try templateScripts(context: context)[script] {
            return templateScriptInfo
        }
        else {
            throw CodeTemplaterError.argumentError(message: "template script '\(script)' does not exist")
        }
    }
}

private extension TemplateScripts {
    /// Creates template info structure from json
    private func templateScriptInfo(infoFilePath: String) throws -> TemplateScriptInfo {
        let templateScriptInfoFile = try File(path: infoFilePath)
        let templateScriptInfoString = try templateScriptInfoFile.readAsString(encodedAs: .utf8)
        let templateScriptInfoData = Data(templateScriptInfoString.utf8)

        do {
            // make sure this JSON is in the format we expect
            guard let info = try JSONSerialization.jsonObject(with: templateScriptInfoData, options: []) as? [String: Any] else {
                throw CodeTemplaterError.generalError(message: "File \(infoFilePath) is not valid JSON.")
            }
            var parameters = [Parameter]()
            if let paramArray = info["parameters"] as? [[String: Any]] {
                for paramDict in paramArray {
                    if let type = paramDict["type"] as? String {
                        switch type {
                        case "bool":
                            parameters.append(try BoolParameter(paramDict))
                        case "string":
                            parameters.append(try StringParameter(paramDict))
                        case "stringArray":
                            parameters.append(try StringArrayParameter(paramDict))
                        default:
                            break
                        }
                    }
                }
            }

            let templateScriptInfo = TemplateScriptInfo(
                completeness: (info["completeness"] as? Int) ?? 0,
                compilable: (info["compilable"] as? Bool) ?? true,
                validationContext: Context(dictionary: (info["validationContext"] as? [String: Any]) ?? [:]),
                preferOriginalLocation: (info["preferOriginalLocation"] as? [String]) ?? [],
                parameters: parameters
            )

            return templateScriptInfo
        }
        catch {
            throw CodeTemplaterError.generalError(message: "File \(infoFilePath) is not valid JSON.")
        }
    }
}
