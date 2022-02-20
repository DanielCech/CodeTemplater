//
//  StringExtension.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Foundation

public extension String {
//    /// Conversion to PascalCase
    func capitalized() -> String {
        let first = String(prefix(1)).uppercased()
        let other = String(dropFirst())
        return first + other
    }

    /// Conversion to PascalCase
    mutating func capitalize() {
        self = capitalized()
    }

    /// Conversion to camelCase
    func decapitalized() -> String {
        let first = String(prefix(1)).lowercased()
        let other = String(dropFirst())
        return first + other
    }

    /// Conversion to camelCase
    mutating func decapitalize() {
        self = decapitalized()
    }

    /// File name modification based on substitutions from context
    func generateName(context: Context) throws -> String {
        var newName = replacingOccurrences(of: ".stencil", with: "")
        newName = try environment.renderTemplate(string: newName, context: context.dictionary)
        return newName
    }

    /// File name modification based on substitutions from context
    func prepareName(name: String) -> String {
        var newName = replacingOccurrences(of: name.capitalized(), with: "{{Name}}")
        newName.append(".stencil")
        return newName
    }
}

// MARK: - Regular expressions

extension String {
    /// Regular expression matches
    func regExpMatches(lineRegExp: String) throws -> [NSTextCheckingResult] {
        let nsrange = NSRange(startIndex..<endIndex, in: self)
        let regex = try NSRegularExpression(pattern: lineRegExp, options: [.anchorsMatchLines])
        let matches = regex.matches(in: self, options: [], range: nsrange)
        return matches
    }

    /// Regular expression matches
    func regExpStringMatches(lineRegExp: String) throws -> [String] {
        let matches = try regExpMatches(lineRegExp: lineRegExp)

        let ranges = matches.compactMap { Range($0.range, in: self) }
        let substrings = ranges.map { self[$0] }
        let strings = substrings.map { String($0) }
        return strings
    }

}
