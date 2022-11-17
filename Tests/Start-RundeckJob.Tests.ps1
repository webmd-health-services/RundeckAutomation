
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

    function ThenReturnsAScheduledExecution
    {
        param(
            $Job
        )

        $script:result | Select-Object -ExpandProperty status | Should -Be 'scheduled'
        
    }

    function ThenReturnsACompletedExecution
    {
        param(
            $Job
        )

        $script:result | Select-Object -ExpandProperty status | Should -Be 'succeeded'
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
            $script:result = Start-RundeckJob -ID $Job[1] -Wait
        }
        elseif ($Schedule) {
            $script:result = Start-RundeckJob -ID $Job[1] -RunAtTime (Get-Date).AddYears(1)
        }
        else
        {
            $script:result = Start-RundeckJob -ID $Job[1]
        }
    }
}

Describe 'Start-RundeckJob' {

    It 'should start a job' {
        $job1 = GivenAJob -Project $script:project

        WhenStartingAJob -Job $job1

        ThenReturnsAnExecution
    }

    It 'should start a job and wait' {
        $job1 = GivenAJob -Project $script:project

        WhenStartingAJob -Job $job1 -Wait

        ThenReturnsACompletedExecution
    }

    It 'should schedule a job' {
        $job1 = GivenAJob -Project $script:project

        WhenStartingAJob -Job $job1 -Schedule

        ThenReturnsAScheduledExecution
    }
}