<#
.SYNOPSIS
Undoes the configuration changes made by the init.ps1 script.

.DESCRIPTION
The reset.ps1 script undoes the configuration changes made by the init.ps1 script. It:

.EXAMPLE
.\reset.ps1

Demonstrates how to call this script.
#>
[CmdletBinding()]
param(
)

Set-StrictMode -Version 'Latest'

if( (Test-Path -Path 'env:APPVEYOR') )
{
    Get-Service 'RUNDECK' | Stop-Service
    & C:\Rundeck\nssm.exe remove RUNDECK
    $msiPath = Join-Path -Path $rundeckPath -ChildPath 'openjdk.msi'
    $msiParameters=@("/qn", "/x", $msiPath)
    Start-Process -FilePath msiexec.exe -ArgumentList $msiParameters -Wait -Passthru
    Remove-Item -Recurse -Force C:\Rundeck
    [System.Environment]::SetEnvironmentVariable('RDECK_BASE', $null)
}
else
{
    Push-Location $PSScriptRoot
    & vagrant destroy -f
    Remove-Item -ErrorAction SilentlyContinue -Force -Path './.hypervip'
    Remove-Item -ErrorAction SilentlyContinue -Force -Path './.vagrant'
    Pop-Location
}
