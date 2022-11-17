
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    [Object[]] $script:result = $null

    function ThenReturnsProject
    {
        param(
            $Project
        )

        $script:result | Where-Object { $_.name -eq $Project } | Should -Not -BeNullOrEmpty
    }

    function WhenGettingAllProjects
    {
        param(
        )

        $script:result = Get-RundeckProject -Filter '*'
    }

    function WhenGettingAProject
    {
        param(
            $Project
        )

        $script:result = Get-RundeckProject -Name $Project
    }
}

Describe 'Get-RundeckJob' {

    It 'should get a project by name' {
        $project1 = GivenAProject

        WhenGettingAProject $project1

        ThenReturnsProject $project1
    }

    It 'should get projects by filter' {
        $project2 = GivenAProject
        $project3 = GivenAProject

        WhenGettingAllProjects

        ThenReturnsProject $project2
        ThenReturnsProject $project3
    }
}