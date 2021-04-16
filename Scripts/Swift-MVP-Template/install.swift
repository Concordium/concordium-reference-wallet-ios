import Foundation

let templateName = "Concordium MVP.xctemplate"
let destinationRelativePath = "Library/Developer/Xcode/Templates/"

func printInConsole(_ message:Any){
    print("====================================")
    print("\(message)")
    print("====================================")
}

func moveTemplate(){

    let fileManager = FileManager.default
    do {
        let destinationPath = "\(fileManager.homeDirectoryForCurrentUser.path)/\(destinationRelativePath)"
        
        //create directory if it does not exist
        if !fileManager.fileExists(atPath:"\(destinationPath)"){
            try fileManager.createDirectory(atPath: destinationPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        if !fileManager.fileExists(atPath:"\(destinationPath)/\(templateName)"){
        
            try fileManager.copyItem(atPath: templateName, toPath: "\(destinationPath)/\(templateName)")
            
            printInConsole("✅  Template installed succesfully 🎉. Enjoy it 🙂")
            
        } else {
            
            try fileManager.removeItem(atPath: "\(destinationPath)/\(templateName)")
            try fileManager.copyItem(atPath: templateName, toPath: "\(destinationPath)/\(templateName)")

            printInConsole("✅  Template already exists. So has been replaced succesfully 🎉. Enjoy it 🙂")
        }
    }
    catch let error as NSError {
        printInConsole("❌  Ooops! Something went wrong 😡 : \(error.localizedFailureReason!)")
    }
}

func shell(launchPath: String, arguments: [String]) -> String
{
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: String.Encoding.utf8)!
    if output.count > 0 {
        //remove newline character.
        let lastIndex = output.index(before: output.endIndex)
        return String(output[output.startIndex ..< lastIndex])
    }
    return output
}

func bash(command: String, arguments: [String]) -> String {
    let whichPathForCommand = shell(launchPath: "/bin/bash", arguments: [ "-l", "-c", "which \(command)" ])
    return shell(launchPath: whichPathForCommand, arguments: arguments)
}

moveTemplate()
