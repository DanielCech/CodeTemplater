//
//  Helpers.swift
//  codeTemplater
//
//  Created by Daniel Cech on 14/09/2020.
//

import Foundation
import Stencil
import Files
import PathKit

/// Definition of stencil environment with support of custom filters
func stencilEnvironment() -> Environment {
    let ext = Extension()

    ext.registerFilter("decapitalized") { (value: Any?) in
        if let value = value as? String {
            return value.decapitalized()
        }

        return value
    }

    ext.registerFilter("capitalized") { (value: Any?) in
        if let value = value as? String {
            return value.capitalized()
        }

        return value
    }

    let environment = Environment(loader: nil, extensions: [ext])
    return environment
}


/// Detailed debug in string
func dumpString(_ something: Any) -> String {
    var dumped = String()
    dump(something, to: &dumped)
    return dumped
}
