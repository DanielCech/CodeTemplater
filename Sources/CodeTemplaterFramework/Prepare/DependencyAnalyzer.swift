//
//  DependencyAnalyzer.swift
//  CodeTemplater
//
//  Created by Daniel Cech on 31/07/2020.
//

import Files
import Foundation

/// Type that covers both type and framework dependencies of particular file
typealias Dependencies = (typeDependencies: Set<String>, frameworkDependencies: Set<String>)

/// Class for analyze of file dependencies
final class DependencyAnalyzer {
    func analyzeFileDependencies(of file: File) throws -> Dependencies {
        let contents = try file.readAsString()

        var typeDependencies = [String]()
        var frameworkDependencies = [String]()

        for line in contents.lines() {
            typeDependencies.append(
                contentsOf: try analyze(line: line, regExp: RegExpPatterns.classPattern)
            )

            typeDependencies.append(
                contentsOf: try analyze(line: line, regExp: RegExpPatterns.structPattern)
            )

            typeDependencies.append(
                contentsOf: try analyze(line: line, regExp: RegExpPatterns.enumPattern)
            )
            typeDependencies.append(
                contentsOf: try analyze(line: line, regExp: RegExpPatterns.protocolPattern)
            )

            typeDependencies.append(
                contentsOf: try analyze(line: line, regExp: RegExpPatterns.extensionPattern)
            )

            typeDependencies.append(
                contentsOf: try analyze(line: line, regExp: RegExpPatterns.letPattern1)
            )

            typeDependencies.append(
                contentsOf: try analyze(line: line, regExp: RegExpPatterns.letPattern2)
            )

            typeDependencies.append(
                contentsOf: try analyze(line: line, regExp: RegExpPatterns.varPattern1)
            )

            typeDependencies.append(
                contentsOf: try analyze(line: line, regExp: RegExpPatterns.varPattern2)
            )

            frameworkDependencies.append(
                contentsOf: try analyze(line: line, regExp: RegExpPatterns.importPattern)
            )
        }

        let typeDependenciesSet = Set(typeDependencies).subtracting(Internals.systemTypes)
        let frameworkDependenciesSet = Set(frameworkDependencies).subtracting(Internals.systemFrameworks)

        Logger.log(indent: 0, string: "    🔎 Type dependencies: \(typeDependenciesSet)")
        Logger.log(indent: 0, string: "    📦 Framework dependencies: \(frameworkDependenciesSet)")

        return (typeDependencies: typeDependenciesSet, frameworkDependencies: frameworkDependenciesSet)
    }

    /// Checking patterns on particular line of file
    func analyze(line: String, regExp: String) throws -> [String] {
        let results = try line.regExpMatches(lineRegExp: regExp)
        var array = [String]()

        for result in results {
            // Process comma separated values
            if let list = extract(line: line, match: result, component: "commalist") {
                let separated = list.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                array.append(contentsOf: separated)
            }

            // Process first part of name
            if let item = extract(line: line, match: result, component: "singleName") {
                if let itemResult = try item.regExpMatches(lineRegExp: RegExpPatterns.singleNamePattern).first {
                    if let name = extract(line: line, match: itemResult, component: "name") {
                        array.append(name)
                    }
                }
            }

            // Exact result
            if let name = extract(line: line, match: result, component: "name") {
                array.append(name)
            }
        }

        return array
    }

    /// Text of particular regular expression match
    func extract(line: String, match: NSTextCheckingResult, component: String) -> String? {
        let nsrange = match.range(withName: component)

        guard
            nsrange.location != NSNotFound,
            let range = Range(nsrange, in: line)
        else {
            return nil
        }

        return String(line[range])
    }

    /// Return dictionary of item definitions in whole project
    func findDefinitions(forTypeDependencies dependencies: Set<String>, context: Context) throws -> [String: String] {
        let sourcesFolder = try Folder(path: context.stringValue(.sourcesPath))
        var resultsDict = [String: String]()

        for sourceFile in sourcesFolder.files.recursive.enumerated() {
            // Only swift files
            guard sourceFile.element.extension?.lowercased() == "swift" else { continue }
            guard let contents = try? sourceFile.element.readAsString() else { continue }

//            Logger.log(indent: 0, string: sourceFile.element.path[sourcesFolder.path.count...])

            for line in contents.lines() {
                for dependency in dependencies {
                    let classResult = try patternMatch(
                        line: line,
                        dependency: dependency,
                        easyCheck: "class ",
                        patterngenerator: RegExpPatterns.classDefinitionPattern
                    )

                    let structResult = try patternMatch(
                        line: line,
                        dependency: dependency,
                        easyCheck: "struct ",
                        patterngenerator: RegExpPatterns.structDefinitionPattern
                    )

                    let enumResult = try patternMatch(
                        line: line,
                        dependency: dependency,
                        easyCheck: "enum ",
                        patterngenerator: RegExpPatterns.enumDefinitionPattern
                    )

                    let protocolResult = try patternMatch(
                        line: line,
                        dependency: dependency,
                        easyCheck: "protocol ",
                        patterngenerator: RegExpPatterns.protocolDefinitionPattern
                    )

                    let typealiasResult = try patternMatch(
                        line: line,
                        dependency: dependency,
                        easyCheck: "typealias ",
                        patterngenerator: RegExpPatterns.typealiasDefinitionPattern
                    )

                    if (classResult ?? structResult ?? enumResult ?? protocolResult ?? typealiasResult) != nil {
                        resultsDict[dependency] = sourceFile.element.path
                    }
                }
            }
        }

        return resultsDict
    }

    /// Preparation of Podfile with Pod framework dependencies
    func createPodfile(forFrameworkDependencies _: Set<String>) throws {}

    /// Checking for regular expression pattern match
    func patternMatch(line: String, dependency: String, easyCheck: String, patterngenerator: (String) -> String) throws -> NSTextCheckingResult? {
        if !line.contains(easyCheck) {
            return nil
        }

        return try line.regExpMatches(lineRegExp: patterngenerator(dependency)).first
    }
}
