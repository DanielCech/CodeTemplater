//
//  Context.swift
//  CodeTemplater
//
//  Created by Daniel Cech on 12/08/2020.
//

import Foundation

/// Context structure type
public class Context {
    var dictionary: [String: Any]

    public init() {
        dictionary = [:]
    }

    /// Initialization from dictionary
    public init(dictionary: [String: Any]) {
        self.dictionary = dictionary
    }

    /// Copy of different context
    public init(fromContext context: Context) {
        dictionary = context.dictionary
    }
}

// MARK: - Debug print

extension Context {
    func debugDescription() -> String {
        let contextDescription = dumpString(self)
        return "context: \(contextDescription)"
    }
}
