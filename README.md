# iOS Framework template

This repository serves as a template for creating new framework in existing iOS projects. The purpose of it is to allow starting modularization efforts without any hustle. It contains a simple, scalable and maintainable definition for a single framework. This definition can be extended to fit the need of any existing iOS project. 

## Prerequisites
The solution is based on framework definition created in `project.yml` file. That file is used to describe the framework, it's configuration, targets, schemes, etc. With that in place we can use one of the greatest tools available [XcodeGen](https://github.com/yonaskolb/XcodeGen)
> XcodeGen is a command line tool written in Swift that generates your Xcode project using your folder structure and a project spec.

That way, hard to  maintain files like `NameOfTheFramework.xcodeproj`, are no longer needed to be versioned in the repository. This file can be regenerated using simple `xcodegen generate` command. If `xcodeproj` file is not part of the repository, it means no more conflicts in this file.
For more info regarding XcodeGen please refer to it's documentation.

## Setup new framework
1. Clone the repository
```bash
# Clone repository to main directory
git clone 'https://github.com/netguru/ios-framework-template'
# Rename cloned repo folder
mv ios-framework-template YourFrameworkName
# Enter the folder
cd YourFrameworkName
# Remove git setup from the framework template
rm -rf .git
```
2. Run the setup script
```
> swift setupTarget.swift
Hello 👋
Welcome in new framework setup script. I will take you thought the whole proces.

➡️  Provide framework name(without spaces):
CoreNetworking

➡️  Provide bundle id prefix you would like to use(follow template: com.company.projectName)
com.acme.client
✅
Setting up the target using new name: CoreNetworking
✅
Updating bundle id's with value: com.acme.client
✅
Running xcodegen
✅
Remove setup script
✅

Would you like to send anonymous statistical data? (y/n)
y
Statistical data sent.
🎉 You are all set here. 🎉
Happy coding!
```
## Configuration alignment
When introducing new module to existing project it is crucial to have the same set of configurations. As in case those are not in line, Xcode will throw an error when building, indicating that our newly created module does not exist(`No such module 'XYZ'`). The fix to that issue is quite simple. Open `ios_framework_template.yml` and replace the configuration definition to match the configuration you already have in the project. Make sure to have exactly the same names(including capitalization)
```yml
configs:
  Development: debug
  Staging: release
  Production: release
```

## Multi framework project
Framework setup make use of template file, allowing multiple frameworks to share common setup.
In order to use single template file for multiple frameworks, move it one level higher and update `project.yml`
```yml
include:
  - path: ../ios_framework_template.yml
    relativePaths: false
```
That way the changes made in `ios_framework_template.yml` will be propagated to all sub frameworks. Thanks to that, adding new Build Setting or changing min supported iOS version will require the change in one single file and running `xcodegen generate` for all frameworks, 1 minute job.

### Example
More complex example how to use xcodegen and our module setup in multi-module project can be found here: https://github.com/netguru/ios-bitrise-client-public

# Contributing

Pull requests and issues are always welcome. Please open any issues and PRs for bugs, features, or documentation. SLA for resolving issues is set to 30 working days.

Current repo maintainer: [Siemian](https://github.com/Siemian)

# License

This framework template is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
