
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    [Object[]] $script:result = $null

    $script:project = GivenAProject

    function ThenReturnsAJob
    {
        param(
            $Job
        )

        [xml]$jobDocument = Get-Content -Path $Job
        $jobObject = $jobDocument.joblist.job
        $script:result | Where-Object { $_.id -eq $jobObject.id } | Should -Not -BeNullOrEmpty
    }

    function ThenReturnsNoJob
    {
        param(
            $Job
        )

        [xml]$jobDocument = Get-Content -Path $Job
        $jobObject = $jobDocument.joblist.job
        $script:result | Where-Object { $_.id -eq $jobObject.id } | Should -BeNullOrEmpty
    }

    function WhenImportingAJob
    {
        param(
            $Job,

            [switch]
            $RemoveUuid
        )

        [xml]$jobDocument = Get-Content -Path $Job
        $jobObject = $jobDocument.joblist.job

        if ($RemoveUuid)
        {
            Import-RundeckJob -Path $Job -ProjectName $script:project -RemoveUuid | Out-Null
        }
        else
        {
            Import-RundeckJob -Path $Job -ProjectName $script:project | Out-Null
        }

        $script:result = Get-RundeckJob -ProjectName $script:project -ID $jobObject.id
    }
}

Describe 'Import-RundeckJob' {

    It 'should import a job from file' {
        $job1 = GivenAJobFile -Project $script:project

        WhenImportingAJob $job1

        ThenReturnsAJob $job1

    }

    It 'should import a job from file with a different ID' {
        $job1 = GivenAJobFile -Project $script:project

        WhenImportingAJob $job1 -RemoveUuid

        ThenReturnsNoJob $job1

    }
}