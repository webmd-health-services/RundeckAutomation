function Get-RundeckJobExecution
{
    <#
    .SYNOPSIS
    Gets a job job execution status from Rundeck.

    .DESCRIPTION
    The `Get-RundeckJobExecution` function gets a job execution status from Rundeck.

    .EXAMPLE
    Get-RundeckJobExecution -ID '406'

    Demonstrates how to get a specific job execution (406) using its ID.
    #>
    param(
        # The execution ID number (usually an incrementing integer in Rundeck global to the server).
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Int16] $ID
    )

    process
    {
        $status = Invoke-RundeckRestMethod -Method 'GET' -ResourcePath "execution/$($ID)"
        return $status
    }
}