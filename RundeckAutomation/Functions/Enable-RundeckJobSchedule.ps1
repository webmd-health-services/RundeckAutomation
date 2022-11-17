function Enable-RundeckJobSchedule
{
    <#
    .SYNOPSIS
    Enables scheduling for a Rundeck job.

    .DESCRIPTION
    The `Enable-RundeckJobSchedule` function enables scheduling for a Rundeck job.

    .EXAMPLE
    Enable-RundeckJobSchedule -ID 'b090d4c8-585c-4330-8bc6-ad4783089dfd'

    Demonstrates how to enable a job.
    #>
    param(
        # The job ID.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Guid] $ID
    )

    process
    {

        return ( Invoke-RundeckRestMethod -Method 'POST' -ResourcePath "job/$($ID)/schedule/enable" )
    }
}