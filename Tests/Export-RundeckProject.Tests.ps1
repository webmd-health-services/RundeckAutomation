
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    [Object[]] $script:result = $null

    function ThenReturnsAFile
    {
        param(
            $Job
        )

        Get-Item -Path $script:result -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Length | Should -BeGreaterOrEqual 1
    }

    function WhenExportingAProject
    {
        param(
            $Project
        )

        $RundeckProjectFile = (New-TemporaryFile).FullName
        Export-RundeckProject -Path $RundeckProjectFile -Name $Project
        $script:result = $RundeckProjectFile
    }
}

Describe 'Export-RundeckProject' {

    It 'should export a job to file' {
        $project1 = GivenAProject

        WhenExportingAProject $project1

        ThenReturnsAFile $project1
    }

}