<p align="center">
    <img src="https://i.ibb.co/qgpJsFT/Code-Templater-Icon.png" width="200" max-width="200" alt="CodeTemplater" />
</p>

# CodeTemplater
CodeTemplater is a command-line tool for generating Swift source code from templates. It is an open-source project written in Swift which a little bit similar to Sourcery. It allows you to create parts of the app using the templates written in Stencil template language. The CodeTemplater can work in four modes: 
* Generate (default) - generation of source code from templates
* Prepare - preparation of templates from source files
* Validate - checking whether templates are valid, eg. whether the generated code is compilable
* Update - management of template inheritance


<p align="center">
    <img src="https://i.ibb.co/jRJsmNG/Code-Templater.png" alt="CodeTemplater" />
</p>


## Installation

<details>
  <summary><strong>Homebrew</strong></summary>

[Homebrew](https://brew.sh) is a favorite package manager for Mac:

This is the preferred installation method. For installation type in your shell:
```bash
$ brew install DanielCech/scripts/codetemplater
```
</details>

<details>
  <summary><strong>Cocoapods</strong></summary>

Installation using Cocoapods is possible but the repo is private under the STRV account.

</details>

## Initial setup
* First thing you need to do is to call `codetemplater init` at the root of your project. It creates the default folder structure within the `templater` folder and it modifies .gitignore. 
* Then you need to put some templates to folder `/templater/Templates`. You can find the separate repository with templates here - https://github.com/strvcom/ios-code-templates-repository. The reason why I keep it separately is that it is better to select some subset of templates rather than use all of them.

# Generate Mode
Generate mode means to produce the code from template and context. The context here is a dictionary-like structure (JSON) that was created by sequential applying and overriding of few sources:

* templater/CodeTemplater.json - the common setup for the project
* templater/CodeTemplaterPersonal.json - the personal settings for the current developer. This file is in .gitignore
* The context explicitly specified with context as parameter
* Other parameters can be specified as command-line arguments
* If some important parameter is missing, CodeTemplater is asking interactively

### Structure of Template
The template is one of the subfolders in `/templater/Templates`. The template has this structure:
* In root there is template.json file with some description
* Template files have `.stencil` extension added to their original extensions
* The file names can contain Stencil expressions - typically the `{{name}}`
* There are some special folders with an underscore that mean the particular place in the project

### Paths
* `projectPath` - the root of project
* `sourcesPath` - the folder where sources are located (subfolder of projectPath)
* `locationPath`  is arbitrary path inside the sourcesPath. It serves as custom destination for generated code
* `testPath` - the path for tests

### Template.json
Let’s take a look at template.json which is in every template. It has a very straightforward structure:
* Text description of template - the meaning and intended use
* Status flag describes the state of template - the possible values are `draft`, `passing` and `failing` - we will talk more about it later
* Parameter `derivedFrom` is for template inheritance - yes templates can be inherited
* There is a definition of template `parameters` - their names, types, and description
* Template can have also its `dependencies`

### Generate in place
* The generation of the source file is not necessarily one-time activity
* We can re-generate the code also later when some change in code or template occurs
* Araxis Merge supports three-way comparison between:
	* Template file
	* Generated file
	* Project file
* There is no risk - the changes between generated and project file are merged manually

### Araxis Merge
* Here is three-way comparison in Araxis Merge

### Don’t lose the context
* Whenever CodeTemplater generates the code, the overall context is stored in `templater/Contexts`folder for future reference
* The file name consists of the name of the generated item and the template
* You can later modify and use the context using codetemplater —context <file> command

### Flexibility of use
The problem of command-line utilities is that they often contain a big amount of parameters and it is necessary to know the syntax. I wanted to minimize writing:
* You can use prepared contexts
* The parameters have often default value
* The selection from the set of options

# Prepare Mode
Up to this moment we expected that we already have some set of prepared templates ready to use. But how we can get them? We can PREPARE them from the existing code. The prepare operation is the opposite of to Generate operation. The process of template preparation is only partially automatic

*Note*: Preparation of template also means to specify the parameter `projectFiles` which is an array of strings. If you add it interactively you can reach the limitation of shell input. The text is truncated to a particular count of characters (tested in iTerm2). The solution is to use `--projectFiles` command line parameter. In this case, you need to put the list of files into quotes (") because the command line parser doesn't support multiple values of some parameter. The string is then divided by spaces concerning escaped spaces when they are part of the file name.

# Validate Mode
There is an assumption that the generated code from the template should be valid. For our purposes, it means that it should be compilable. It is quite easy to introduce some problems into the template. I recommend using some syntax highlighting for Stencil which is available for both Visual Studio Code and Atom.
The validation works like this:
	* The generated code is injected to empty Xcode project and it will try to compile
	* If the template depends on various bool parameters and and `if`s, it is necessary to check all possible combinations
When validation succeeds, the template status is passing.

# Update Mode
The update is the last mode and it is very simple. The templates can be derived one from other. When the template is changed we often want to compare the changes also with the parent or child template.


##  CodeTemplater

- [Requirements](#requirements)
- [Installation](#installation)
- [License](#license)

## Requirements

- Mac OS X 10.15+ 
- Xcode 10.0+



## Syntax highlighting setup for Araxis Merge
* Filename: _*.swift;*.stencil_
* Keywords 1: _associatedtype class deinit enum extension fileprivate func import init inout internal let open operator private protocol public rethrows static struct subscript typealias var_
* Keywords 2: _break case continue default defer do else fallthrough for guard if in repeat return switch where while as Any catch false is nil super self Self throw throws true try_
* Keywords 3: _#available #colorLiteral #column #else #elseif #endif #error #file #filePath #fileLiteral #function #if #imageLiteral #line #selector #sourceLocation #warning_


## Useful Links
* Stencil Highlighting for Visual Studio Code - https://stencil.fuller.li/en/latest/
* Stencil Highlighting for Atom - https://atom.io/packages/language-stencil

## Contributing

Issues and pull requests are welcome!

## Author

* Daniel Čech [GitHub](https://github.com/DanielCech)

## License

CodeTemplater is released under the MIT license. See [LICENSE](https://github.com/DanielCech/DeallocTests/blob/master/LICENSE) for details.
