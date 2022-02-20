import Files
import Foundation
import Moderator
import ScriptToolkit
import CodeTemplaterFramework


/// Main entry point of the script

do {
    let codeTemplater = CodeTemplater()
    
    let context = try codeTemplater.initializeContext()

    // Script parts creation with their dependencies
    codeTemplater.initializeComponents()

    print("⌚️ Processing")

    // Script action based on selected mode
    switch ProgramMode(rawValue: context.stringValue(.mode))  {
     case .generate:
        try codeTemplater.generateCode(context: context)

    default:
        throw CodeTemplaterError.argumentError(message: "invalid mode value")
    }
    
    try codeTemplater.saveContext(context)

    print("✅ Done")

}
catch {
    // Report possible error
    if let printableError = error as? PrintableError {
        print(printableError.errorDescription)
    }
    else {
        print(error.localizedDescription)
    }

    exit(Int32(error._code))
}
