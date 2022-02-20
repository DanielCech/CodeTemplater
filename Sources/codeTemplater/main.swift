import CodeTemplaterFramework
import Files
import Foundation
import Moderator
import ScriptToolkit

/// Main entry point of the script

do {
    Logger.getTerminalWidth()
    
    let codeTemplater = CodeTemplater()

    let context = try codeTemplater.initializeContext()
    try codeTemplater.process(context: context)

    // Script parts creation with their dependencies
    codeTemplater.initializeComponents()

    Logger.log(indent: 0, string: "⌚️ Processing")

    // Script action based on selected mode
    switch context.stringValue(.mode) {
    case ProgramMode.generate.rawValue:
        try codeTemplater.generateCode(context: context)

    case ProgramMode.validate.rawValue:
        try codeTemplater.validate(context: context)
        
    case ProgramMode.prepare.rawValue:
        try codeTemplater.prepareTemplate(context: context)

    default:
        throw CodeTemplaterError.argumentError(message: "invalid mode value")
    }

    try codeTemplater.saveContext(context)

    Logger.log(indent: 0, string: "✅ Done")
}
catch {
    // Report possible error
    if let printableError = error as? PrintableError {
        Logger.log(indent: 0, string: printableError.errorDescription)
    }
    else {
        Logger.log(indent: 0, string: error.localizedDescription)
    }

    exit(Int32(error._code))
}
