<#
.SYNOPSIS
Gets your computer ready to develop the RundeckAutomation module.

.DESCRIPTION
The init.ps1 script makes the configuraion changes necessary to get your computer ready to develop for the
RundeckAutomation module. It:


.EXAMPLE
.\init.ps1

Demonstrates how to call this script.
#>
[CmdletBinding()]
param(
)

function Start-InstallProcess
{
    param(
        [string]$ExecutablePath,
        [string[]]$ExecutableParameters
    )

    $javaProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
    $javaProcessInfo.FileName = $ExecutablePath
    $javaProcessInfo.RedirectStandardError = $true
    $javaProcessInfo.RedirectStandardOutput = $true
    $javaProcessInfo.UseShellExecute = $false
    $javaProcessInfo.Arguments = ($ExecutableParameters -Join ' ')
    $javaProcess = New-Object System.Diagnostics.Process
    $javaProcess.StartInfo = $javaProcessInfo
    $javaProcess.Start() | Out-Null
    $javaProcess.WaitForExit()
    $stdout = $javaProcess.StandardOutput.ReadToEnd()
    $stderr = $javaProcess.StandardError.ReadToEnd()

    return @{stdout = $stdout; stderr = $stderr}
}

Set-StrictMode -Version 'Latest'
$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'
$VerbosePreference = 'Continue'

Write-Host 'Starting init.ps1 script'

$openJdkVersion = '11.0.16.1'
$rundeckVersion = '4.6.1-20220914'
$rundeckPath = 'C:\rundeck'
$rundeckWarFile = Join-Path -Path $rundeckPath -ChildPath 'rundeck.war'
$nssmVersion = '2.24'
$msiPath = Join-Path -Path $rundeckPath -ChildPath 'openjdk.msi'
$msiLogPath = Join-Path -Path $rundeckPath -ChildPath 'openjdk.log'
$zipPath = Join-Path -Path $rundeckPath -ChildPath 'nssm.zip'
$nssmPath = Join-Path -Path $rundeckPath -ChildPath 'nssm.exe'

Write-Verbose (Get-Variable | Format-Table | Out-String)
Write-Verbose ''
Write-Verbose (Get-ChildItem ENV: | Format-Table -Wrap | Out-String)
Write-Verbose ''

New-Item -ItemType Directory -Path $rundeckPath

Write-Host 'Install OpenJDK'
Invoke-WebRequest -UseBasicParsing -Uri "https://aka.ms/download-jdk/microsoft-jdk-$($openJdkVersion)-windows-x64.msi" -OutFile $msiPath -MaximumRedirection 10
if (Test-Path $msiPath)
{
    $msiParameters=@("/qn", "/l*", $msiLogPath, "/i", $msiPath)
    $msiExitCode = (Start-Process -FilePath msiexec.exe -ArgumentList $msiParameters -Wait -Passthru).ExitCode
    if ($msiExitCode -ne 0)
    {
        Get-Content -Path $msiLogPath
        Write-Error "MSIExec failed $($msiExitCode)."
    }
    else
    {
        $javaPath = Get-ChildItem -Recurse -Force -ErrorAction Ignore -Path 'C:\Program Files\Microsoft' -Filter 'java.exe' | Select-Object -ExpandProperty FullName
        if ($javaPath.GetType().Name -eq 'String')
        {
            $javaVersion = Start-InstallProcess -ExecutablePath $javaPath -ExecutableParameters @('-version')
            Write-Host $javaVersion.stderr
            Write-Host 'Installed OpenJDK'
        }
        else
        {
            Write-Error "Wrong number of java runtimes found."
        }
        
    }
}
else
{
    Write-Error "$($msiPath) missing."
}

Write-Host 'Install Rundeck'
Invoke-WebRequest -UseBasicParsing -Uri "https://packagecloud.io/pagerduty/rundeck/packages/java/org.rundeck/rundeck-$($rundeckVersion).war/artifacts/rundeck-$($rundeckVersion).war/download" -OutFile $rundeckWarFile
[System.Environment]::SetEnvironmentVariable('RDECK_BASE', $rundeckPath)
$rundeckInstall = Start-InstallProcess -ExecutablePath $javaPath -ExecutableParameters @('-jar', $rundeckWarFile, '--installonly')
Write-Host $rundeckInstall.stdout
if ($rundeckInstall.stderr)
{
    Write-Host $rundeckInstall.stderr
    Write-Error "Rundeck installation failed"
}
Copy-Item -Path (Join-Path -Path $($PSScriptRoot) -ChildPath 'vagrant\start_rundeck.bat') -Destination 'C:\rundeck\start_rundeck.bat'
New-Item -ItemType Directory -Path (Join-Path -Path $rundeckPath -ChildPath '\var\log')

Write-Host 'Install Rundeck NSSM Windows service'
Invoke-WebRequest -UseBasicParsing -Uri "http://nssm.cc/release/nssm-$($nssmVersion).zip" -OutFile $zipPath
Expand-Archive -Path $zipPath -DestinationPath $rundeckPath
$nssmPath = Get-ChildItem -Recurse -Force -ErrorAction Ignore -Path $rundeckPath -Filter 'nssm.exe' | Where-Object { $_.FullName -match 'win64' } | Select-Object -ExpandProperty FullName
if ($nssmPath.GetType().Name -eq 'String')
{
    $nssmInstall = Start-InstallProcess -ExecutablePath $nssmPath -ExecutableParameters @('install', 'RUNDECK', 'C:\Rundeck\start_rundeck.bat')
    Write-Host $nssmInstall.stdout
    if ($nssmInstall.stderr)
    {
        Write-Host $nssmInstall.stderr
        Write-Error 'NSSM failed to install.'
    }
    $nssmInstall = Start-InstallProcess -ExecutablePath $nssmPath -ExecutableParameters @('set', 'RUNDECK', 'AppDirectory', $rundeckPath)
    Write-Host $nssmInstall.stdout
    if ($nssmInstall.stderr)
    {
        Write-Host $nssmInstall.stderr
        Write-Error 'NSSM failed to install.'
    }
    Write-Host 'Installed NSSM and service'
}
else
{
    Write-Error "Wrong number of nssm runtimes found."
}
$rundeckAccessList = Get-ACL -Path $rundeckPath
$rundeckAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule('NT AUTHORITY\LOCAL SERVICE', 'Modify', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
$rundeckAccessList.SetAccessRule($rundeckAccessRule)
$rundeckAccessList | Set-Acl -Path $rundeckPath

Write-Host 'Install done.  Starting Service.'
Start-Service -Name 'RUNDECK'
Start-Sleep -Seconds 5
$maxTries = 20
$i = 0
while (((Get-Content -Path 'C:\rundeck\var\log\service.log' -ErrorAction SilentlyContinue) -notcontains 'Grails application running at http://localhost:4440 in environment: production') -and ($i -lt $maxTries))
{
    Write-Host 'Waiting 30 seconds for site to start...'
    Start-Sleep -Seconds 30
    ++$i  
}

while (((Invoke-WebRequest -ErrorAction SilentlyContinue -UseBasicParsing -Uri 'http://localhost:4440').Content -notmatch 'Rundeck - Login' ) -and ($i -lt $maxTries))
{
    Write-Host 'Waiting 30 seconds for site to initialize...'
    Start-Sleep -Seconds 30
    ++$i
}

Write-Host 'Done with init.ps1 script'
