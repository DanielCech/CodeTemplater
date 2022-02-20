//
//  StringExtension.swift
//  CodeTemplates
//
//  Created by Daniel Cech on 13/06/2020.
//

import Foundation

public extension String {
    /// File name modification based on substitutions from context
    func generateName(context: Context) throws -> String {
        var newName = replacingOccurrences(of: ".stencil", with: "")
        newName = try environment.renderTemplate(string: newName, context: context.dictionary)
        return newName
    }

    /// File name modification based on substitutions from context
    func prepareName(name: String) -> String {
        var newName = replacingOccurrences(of: name.capitalized(), with: "{{name}}")
        newName.append(".stencil")
        return newName
    }
    
    /// Returns the path without trailing slash
    func withoutSlash() -> String {
        if last == "/" {
            return String(prefix(count - 1))
        }
        return self
    }
}

extension String {
    static let none = "<none>"
}
