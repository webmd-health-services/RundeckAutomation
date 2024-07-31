function Remove-RundeckJob
{
    <#
    .SYNOPSIS
    Removes a Rundeck job.

    .DESCRIPTION
    The `Remove-RundeckJob` function removes a Rundeck job.

    .EXAMPLE
    $job = Get-RundeckJob -ProjectName 'demoproject' -Name 'demojob'
    Remove-RundeckJob -ID $job.id

    Demonstrates how to remove the 'demojob' job from the 'demoproject' project
    #>
    [CmdletBinding()]
    param(
        # The job's ID.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Guid] $ID
    )

    process
    {
        Invoke-RundeckRestMethod -Method 'DELETe' -ResourcePath "/api/11/job/$($ID)"
    }
}