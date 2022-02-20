//
//  Helpers.swift
//  codeTemplater
//
//  Created by Daniel Cech on 14/09/2020.
//

import Files
import Foundation
import PathKit
import Stencil

/// Definition of stencil environment with support of custom filters
func stencilEnvironment() -> Environment {
    let ext = Extension()

    // First letter is capitalizad - in uppercase
    ext.registerFilter("decapitalized") { (value: Any?) in
        if let value = value as? String {
            return value.decapitalized()
        }

        return value
    }

    // First letter is decapitalized - in lowercase
    ext.registerFilter("capitalized") { (value: Any?) in
        if let value = value as? String {
            return value.capitalized()
        }

        return value
    }
    
    // If input is not empty, the comma and space is added
    ext.registerFilter("comma") { (value: Any?) in
        if let value = value as? String {
            return value.isEmpty ? "" : value + ", "
        }

        return value
    }
    
    let environment = Environment(loader: nil, extensions: [ext])
    return environment
}

