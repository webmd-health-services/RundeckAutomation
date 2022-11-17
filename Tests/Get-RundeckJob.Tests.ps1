
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    [Object[]] $script:result = $null

    $script:project = GivenAProject

    function ThenReturnsJob
    {
        param(
            $Job
        )

        $script:result | Where-Object { $_.id -eq $Job[1] } | Should -Not -BeNullOrEmpty
    }

    function WhenGettingAllJobs
    {
        param(
        )

        $script:result = Get-RundeckJob -ProjectName $script:project -Filter '*'
    }

    function WhenGettingAJob
    {
        param(
            $Job
        )

        $script:result = Get-RundeckJob -ProjectName $script:project -Name $Job[0]
    }
}

Describe 'Get-RundeckJob' {

    It 'should get a job in a project by name' {
        $job1 = GivenAJob -Project $script:project

        WhenGettingAJob $job1

        ThenReturnsJob $job1
    }

    It 'should get jobs in a project by filter' {
        $job2 = GivenAJob -Project $script:project
        $job3 = GivenAJob -Project $script:project

        WhenGettingAllJobs

        ThenReturnsJob $job2
        ThenReturnsJob $job3
    }

}