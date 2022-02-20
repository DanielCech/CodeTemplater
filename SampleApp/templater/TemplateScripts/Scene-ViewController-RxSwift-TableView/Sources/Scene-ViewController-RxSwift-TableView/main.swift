import CodeTemplaterFramework

let codeTemplater = CodeTemplater()

let context = try codeTemplater.initializeContext()
context[.context] = "/Users/danielcech/Documents/[Development]/[Projects]/ios-code-templates/SampleApp/templater/TemplateCombos/Scene-ViewController-RxSwift-TableView/lastContext.json"

// Script parts creation with their dependencies
codeTemplater.initializeComponents()

// Generate view controller
try codeTemplater.generateCode(context: context)

//
//
// try codeTemplater.generateCode(context: context, generationMode: .template("ViewModelAssembly"), deleteGenerate: false)
// try codeTemplater.generateCode(context: context, generationMode: .template(storyboardTemplate), deleteGenerate: false)
//
//// Generate new table view cells
// if let unwrappedNewCells = context[.newTableViewCells] {
//     for cell in unwrappedNewCells {
//         let modifiedContext = updateComboContext(context, name: cell)
//         try generator.generate(context: modifiedContext, generationMode: .template("TableViewCell-RxSwift"), deleteGenerate: false)
//     }
// }
//
// // Generate coordinator
// guard let coordinator = context[.coordinator] else { return }
// let modifiedContext = updateComboContext(context, name: coordinator) // TODO: check the name and suffix Coordinator, Coordinating
// modifiedContext[.controllers] = [context.stringValue(.name)]
// try generator.generate(context: modifiedContext,generationMode: .template("Coordinator-Navigation"), deleteGenerate: false)
//
