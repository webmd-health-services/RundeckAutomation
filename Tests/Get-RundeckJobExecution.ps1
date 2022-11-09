
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    [Object[]] $script:result = $null

    $script:project = GivenAProject

    function ThenReturnsAnExecution
    {
        param(
            $Job
        )

        $script:result | Select-Object -ExpandProperty status | Should -Be 'running'
    }

    function WhenStartingAJob
    {
        param(
            $Job,
            [switch]
            $Wait,
            [switch]
            $Schedule
        )

        if ($Wait)
        {
            $script:result = Get-RundeckJobExecution -ID $Job[1] -Wait
        }
        elseif ($Schedule) {
            $script:result = Get-RundeckJobExecution -ID $Job[1] -RunAtTime (Get-Date).AddYears(1)
        }
        else
        {
            $script:result = Get-RundeckJobExecution -ID $Job[1]
        }
    }
}

Describe 'Get-RundeckJobExecution' {

    It 'should get a job execution' {
        $job1 = GivenAJob -Project $script:project

        WhenStartingAJob -Job $job1

        ThenReturnsAnExecution
    }

}