function Disable-RundeckJobSchedule
{
    <#
    .SYNOPSIS
    Disables scheduling for a Rundeck job.

    .DESCRIPTION
    The `Disable-RundeckJobSchedule` function disables scheduling for a Rundeck job.

    .EXAMPLE
    Disable-RundeckJobSchedule -ID 'b090d4c8-585c-4330-8bc6-ad4783089dfd'

    Demonstrates how to disable a job.
    #>
    param(
        # The job ID.    
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [GUID]
        $ID
    )

    process
    {

        return ( Invoke-RundeckRestMethod -Method 'POST' -ResourcePath "job/$($ID)/schedule/disable" )
    }
}