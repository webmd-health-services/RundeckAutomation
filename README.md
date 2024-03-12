# RundeckAutomation Module

## Overview

The "RundeckAutomation" module...

## System Requirements

* Windows PowerShell 5.1 and .NET 4.6.1+
* PowerShell Core 6+

## Installing

To install globally:

```powershell
Install-Module -Name 'RundeckAutomation'
Import-Module -Name 'RundeckAutomation'
```

To install privately:

```powershell
Save-Module -Name 'RundeckAutomation' -Path '.'
Import-Module -Name '.\RundeckAutomation'
```

## Getting Started

First, import the Rundeck Automation module:

```powershell
    Import-Module 'Path\To\RundeckAutomation'
```

If you put it in one of your `PSModulePath` directories, you can omit the path:

```powershell
    Import-Module 'RundeckAutomation'
```

Next, create a connection object to the instance of Rundeck you want to use.

```powershell
    $session = New-RundeckSession -Uri 'https://Rundeck.example.com' -Credential (Get-Credential)
```

To see a full list of available commands:

```powershell
    Get-Command -Module 'RundeckAutomation'
```

You can always call an API using `Invoke-RundeckRestMethod`:

```powershell
    Invoke-RundeckRestMethod -Method 'Get' -ResourcePath 'system/info'
```

## Contributing

Contributions are welcome and encouraged!

* Test scripts go in the `Tests` directory. New module functions go in the `RundeckAutomation\Functions` directory.
* Update the changelog and, if functionality changed, the readme.
* Create a pull request.

## Testing

We use [Whiskey](https://github.com/webmd-health-services/Whiskey) to build, test, and publish the module. [Pester](https://github.com/pester/Pester) is the testing framework used for our tests.  [Vagrant](https://www.vagrantup.com/) is used for local development and testing.

* Run the following to run all tests

```powershell
.\build.ps1
```

* Run the following to run a single test

```powershell
.\init.ps1
Import-Module -Name '.\PSModules\Pester'
Invoke-Pester
```

* Run the following to clean up

```powershell
.\reset.ps1
```
