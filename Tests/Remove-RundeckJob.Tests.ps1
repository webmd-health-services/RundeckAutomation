
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    [Object[]] $script:result = $null

    $script:project = GivenAProject

    function ThenReturnsNoJob
    {
        param(
            $Job
        )

        $script:result | Where-Object { $_.id -eq $Job[1] } | Should -BeNullOrEmpty
    }

    function WhenRemovingAJob
    {
        param(
            $Job
        )

        Remove-RundeckJob -ID $Job[1] | Out-Null
        $script:result = Get-RundeckJob -ProjectName $script:project -Filter '*'
    }

}

Describe 'Remove-RundeckJob' {

    It 'should remove a job from Rundeck' {
        $job1 = GivenAJob -Project $script:project

        WhenRemovingAJob $job1

        ThenReturnsNoJob $job1
    }

}