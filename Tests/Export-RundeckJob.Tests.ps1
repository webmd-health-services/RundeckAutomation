
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    [Object[]] $script:result = $null

    $script:project = GivenAProject

    function ThenReturnsAFile
    {
        param(
            $Job
        )

        Get-Item -Path $script:result -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Length | Should -BeGreaterOrEqual 1
    }

    function WhenExportingAJob
    {
        param(
            $Job
        )

        $rundeckJobFile = (New-TemporaryFile).FullName
        Export-RundeckJob -Path $rundeckJobFile -ProjectName $script:project -ID $Job[1]
        $script:result = $rundeckJobFile
    }
}

Describe 'Export-RundeckJob' {

    It 'should export a job to file' {
        $job1 = GivenAJob -Project $script:project

        WhenExportingAJob $job1

        ThenReturnsAFile $job1
    }

}