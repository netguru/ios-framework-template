#!/usr/bin/env swift
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
/*
  Helper functions
*/

@discardableResult func runProcess(_ command: String) -> String? {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = command.split(separator: " ").map { String($0) }
    let pipe = Pipe()
    process.standardOutput = pipe
    try? process.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: String.Encoding.utf8)
}

func bold(_ text: String) -> String {
  "\u{001B}[1m" + text + "\u{001B}[0m"
}

func printBold(_ text: String) {
  print(bold(text))
}

func loadFile(_ name: String) -> String {
  try! String(contentsOfFile: name, encoding: .utf8)
}

func writeText(_ text: String, to fileName: String) {
  try! text.write(to: URL(fileURLWithPath: fileName), atomically: true, encoding: .utf8)
}

func runRename(for pattern: String) {
  // Workaround for sed issue.
  let command = "LC_CTYPE=C LANG=C find . -type f -not -path '*/\\.git/*' -exec sed -i ''  -e \(pattern) {} +"
  writeText(command, to: "rename.sh")
  runProcess("bash rename.sh")
  runProcess("rm rename.sh")
}

func escapeForRegex(_ text: String) -> String {
  text.replacingOccurrences(of: ".", with: "\\.").replacingOccurrences(of: "/", with: "\\/")
}

/*
  Validate required tools are installed
*/
["xcodegen"].forEach { tool in
  let output = runProcess("which \(tool)")!
  if output.contains("not found") || output.isEmpty {
    printBold("\(tool) is not installed, please install it first!")
    exit(1)
  }
}

/*
  Gather user input
*/

printBold("Hello 👋")

print("Welcome in new framework setup script. I will take you thought the whole proces.")
printBold("\n➡️  Provide framework name(without spaces):")
var name = readLine(strippingNewline: true)!
printBold("\n➡️  Provide bundle id prefix you would like to use(follow template: com.company.projectName)")
var bundleId = readLine(strippingNewline: true)!
/*
  Update template
*/

print("✅")

print("\nRenaming directories")

let command = "find . -name '*CoreFramework*' -exec bash -c 'mv \"$0\" \"${0/CoreFramework/\(name)}\"' {} +"
writeText(command, to: "rename.sh")
runProcess("bash rename.sh")
runProcess("bash rename.sh")
runProcess("rm rename.sh")

print("✅")

print("Setting up the target using new name: \(name)")
runRename(for: "s/CoreFramework/\(name)/g")
print("✅")

print("Updating bundle id's with value: \(bundleId)")
let escapedBundleId = escapeForRegex(bundleId)
runRename(for: "s/com\\.xcodegenDemo/\(escapedBundleId)/g")
print("✅")

print("Running xcodegen")
runProcess("xcodegen generate")
print("✅")


print("Remove setup script")
//runProcess("rm setupTarget.swift")
//runProcess("rm README.md")
print("✅")

printBold("\nWould you like to send anonymous statistical data? (y/n)")
var shareStats = readLine(strippingNewline: true)!
guard shareStats == "y" else {
  exit(0)
}

extension String {
  var urlEncoded: String {
    self.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
  }
}
var semaphore = DispatchSemaphore (value: 0)
let params = "app_name=\(name.urlEncoded)&bundle_id=\(bundleId.urlEncoded)"
let urlString = "https://hooks.zapier.com/hooks/catch/4193197/3ro9i2g/?\(params)"

var request = URLRequest(url: URL(string: urlString)!, timeoutInterval: 50)
request.httpMethod = "POST"

let task = URLSession.shared.dataTask(with: request) { data, response, error in
  guard let _ = data else {
    print("Statistical data not sent.")
    print(String(describing: error))
    semaphore.signal()
    return
  }
  print("Statistical data sent.")
  semaphore.signal()
}

task.resume()
semaphore.wait()

printBold("🎉 You are all set here. 🎉")
printBold("Happy coding!")
