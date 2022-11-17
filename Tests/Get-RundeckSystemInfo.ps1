
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    [Object[]] $script:result = $null

    $script:project = GivenAProject

    function ThenReturnsInfo
    {
        param(
            $Job
        )

        $script:result | Should -Not -BeNullOrEmpty
    }

    function WhenGettingInfo
    {
        param(
        )

        $script:result = Get-RundeckSystemInfo

    }
}

Describe 'Get-RundeckSystemInfo' {

    It 'should get the system info' {

        WhenGettingInfo

        ThenReturnsInfo
    }

}