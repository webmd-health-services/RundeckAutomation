# Overview

The "RundeckAutomation" module...

# System Requirements

* Windows PowerShell 5.1 and .NET 4.6.1+
* PowerShell Core 6+

# Installing

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

# Getting Started

First, import the Rundeck Automation module:

    Import-Module 'Path\To\RundeckAutomation'
    
If you put it in one of your `PSModulePath` directories, you can omit the path:

    Import-Module 'RundeckAutomation'
 
Next, create a connection object to the instance of Rundeck you want to use.

    $session = New-RundeckSession -Uri 'https://Rundeck.example.com' -Credential (Get-Credential)

To see a full list of available commands:

    Get-Command -Module 'RundeckAutomation'
    
You can always call an API using `Invoke-RundeckRestMethod`:

    Invoke-RundeckRestMethod -Method 'Get' -ResourcePath 'system/info'
