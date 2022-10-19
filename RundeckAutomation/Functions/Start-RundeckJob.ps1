function Start-RundeckJob
{
    <#
    .SYNOPSIS
    Starts a job from Rundeck.

    .DESCRIPTION
    The `Start-RundeckJob` function starts a job from Rundeck.

    .EXAMPLE
    Start-RundeckJob -ID 'b090d4c8-585c-4330-8bc6-ad4783089dfd'

    Demonstrates how to start a specific job usng its ID.
    #>
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='ByID')]
        [guid]
        # The job's ID.
        $ID,

        [switch]
        # Wait for job to complete or fail.
        $Wait
    )

    process
    {
        $jobRun = Invoke-RundeckRestMethod -Method 'POST' -ResourcePath "job/$($ID)/executions"
        Start-Sleep -Seconds 1

        if ($Wait)
        {
            while ($jobRun.status -eq 'running')
            {
                Start-Sleep -Seconds 10
                $jobRun = Get-RundeckJobExecution -Uri $jobRun.permalink
            }
        }
        return $jobRun
    }
}