//
//  Logger.swift
//  CodeTemplaterFramework
//
//  Created by Daniel Cech on 20/03/2021.
//

import Foundation
import ScriptToolkit

final public class Logger {
    private(set) static var columns: Int = 80
    
    public static func getTerminalWidth() {
        let columnsString = shell("tput -T xterm-256color cols")
        if let columns = Int(columnsString.dropLast()) {
            Logger.columns = columns
        }
    }
    
    public static func log(indent: Int, string: String, terminator: String = "\n") {
        let indentString = String(repeating: "    ", count: indent)
        let indentSize = 4 * indent
        
        for line in string.split(by: Logger.columns - indentSize) {
            print(indentString + line, terminator: terminator)
        }
        
    }
}
