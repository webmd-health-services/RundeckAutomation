
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    [Object[]] $script:result = $null

    $script:project = GivenAProject

    function ThenReturnsADisabledJob
    {
        param(
            $Job
        )

        $script:result | Where-Object { $_.scheduleEnabled } | Should -BeNullOrEmpty
    }

    function WhenDisablingAJob
    {
        param(
            $Job
        )

        Disable-RundeckJobSchedule -ID $Job[1]

        $script:result = Get-RundeckJob -ProjectName $script:project -ID $Job[1]
    }
}

Describe 'Disable-RundeckJobSchedule' {

    It 'should disable an enabled job' {
        $job1 = GivenAJob -Project $script:project

        WhenDisablingAJob $job1

        ThenReturnsADisabledJob $job1
    }

}