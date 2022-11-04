function Get-RundeckJobExecution
{
    <#
    .SYNOPSIS
    Gets a job job execution status from Rundeck.

    .DESCRIPTION
    The `Get-RundeckJobExecution` function gets a job execution status from Rundeck.

    .EXAMPLE
    Get-RundeckJobExecution -Uri 'https://rundeck.test.webmdhealth.com/api/41/execution/406'

    Demonstrates how to get a specific job execution for job "41" usng its URI.
    #>
    param(
        # The job's name.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName='ByUri')]
        [string]
        $Uri
    )

    process
    {
        $status = Invoke-RundeckRestMethod -Method 'GET' -ResourcePath $Uri
        return $status
    }
}