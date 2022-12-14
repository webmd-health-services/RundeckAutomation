
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

function GivenModuleLoaded
{
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\RundeckAutomation\RundeckAutomation.psd1' -Resolve)
    Get-Module -Name 'RundeckAutomation' | Add-Member -MemberType NoteProperty -Name 'NotReloaded' -Value $true
}

function GivenModuleNotLoaded
{
    Remove-Module -Name 'RundeckAutomation' -Force -ErrorAction Ignore
}

function Init
{

}

function ThenModuleLoaded
{
    $module = Get-Module -Name 'RundeckAutomation'
    $module | Should -Not -BeNullOrEmpty
    $module | Get-Member -Name 'NotReloaded' | Should -BeNullOrEmpty
}

function WhenImporting
{
    $script:importedAt = Get-Date
    Start-Sleep -Milliseconds 1
    & (Join-Path -Path $PSScriptRoot -ChildPath '..\RundeckAutomation\Import-RundeckAutomation.ps1' -Resolve)
}

Describe 'Import-RundeckAutomation.when module not loaded' {
    It 'should import the module' {
        Init
        GivenModuleNotLoaded
        WhenImporting
        ThenModuleLoaded
    }
}

Describe 'Import-RundeckAutomation.when module loaded' {
    It 'should re-import the module' {
        Init
        GivenModuleLoaded
        WhenImporting
        ThenModuleLoaded
    }
}
