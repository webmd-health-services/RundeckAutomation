
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    [Object[]] $script:result = $null

    $script:project = GivenAProject

    function ThenReturnsAProject
    {
        param(
            $ProjectFile,
            $ProjectConfig
        )

        if ($ProjectFile)
        {
            [xml]$projectDocument = Get-Content -Path $ProjectFile
            $projectObject = $projectDocument.project
        }
        else
        {
            $projectObject = $ProjectConfig | ConvertFrom-Json
        }

        $script:result | Where-Object { $_.name -eq $projectObject.name } | Should -Not -BeNullOrEmpty
    }

    function WhenImportingAProjectFile
    {
        param(
            $Project
        )

        [xml]$projectDocument = Get-Content -Path $Project
        $projectObject = $projectDocument.project
        Import-RundeckProject -File $Project | Out-Null
        $script:result = Get-RundeckProject -Name $projectObject.name
        
    }

    function WhenImportingAProjectConfig
    {
        param(
            $Project
        )

        Import-RundeckProject -Config $Project | Out-Null
        $projectObject = $ProjectConfig | ConvertFrom-Json
        $script:result = Get-RundeckProject -Name $projectObject.name
        
    }
}

Describe 'Import-RundeckProject' {

    It 'should import a project from file' {
        $project1 = GivenAProjectFile -AsXml

        WhenImportingAProjectFile $project1

        ThenReturnsAProject -ProjectFile $project1

    }

    # It 'should import a project from JSON config' {
    #     $project1 = GivenAProjectFile

    #     WhenImportingAProjectConfig $project1

    #     ThenReturnsAProject -ProjectConfig $project1

    # }
}