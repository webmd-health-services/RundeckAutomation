
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    [Object[]] $script:result = $null

    function ThenReturnsNoProject
    {
        param(
            $Project
        )

        $script:result | Where-Object { $_.name -eq $Project } | Should -BeNullOrEmpty
    }

    function WhenRemovingAProject
    {
        param(
            [string]$Project
        )

        Remove-RundeckProject -Name $Project | Out-Null
        $script:result = Get-RundeckProject -Filter '*'
    }

}

Describe 'Remove-RundeckProject' {

    It 'should remove a Project from Rundeck' {
        $project1 = GivenAProject

        WhenRemovingAProject $project1

        ThenReturnsNoProject $project1
    }

}