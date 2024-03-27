
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

Describe 'Export-RundeckProject' {

    BeforeAll {
        & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
    
        [Object[]] $script:result = $null
    
        function ThenReturnsAFile
        {
            param(
                $File
            )

            Get-Item -Path $File -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Length | Should -BeGreaterOrEqual 1
        }
    
        function ThenReturnsAZipFile
        {
            param(
                $File
            )

            $rootPath = (Get-Item $PSScriptRoot).Parent
            Import-Module -Name (Join-Path -Path $rootPath.FullName -ChildPath 'PSModules\Carbon' -Resolve)
            Test-CZipFile -Path $File
        }

        function WhenExportingAProject
        {
            param(
                $Project
            )
    
            $RundeckProjectFile = (New-TemporaryFile).FullName
            Export-RundeckProject -Path $RundeckProjectFile -Name $Project | Out-Null
            return $RundeckProjectFile
        }
    }

    It 'should export a job to file' {
        $project1 = GivenAProject

        $outputFile = WhenExportingAProject $project1

        ThenReturnsAFile -File $outputFile

        ThenReturnsAZipFile -File $outputFile

    }

}