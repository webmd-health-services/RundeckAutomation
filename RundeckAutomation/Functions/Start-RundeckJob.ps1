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
        # The job's ID.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName='ByID')]
        [guid]
        $ID,

        # The optional time to start the job.
        [datetime]
        $RunAtTime,

        # Wait for job to complete or fail.
        [switch]
        $Wait,

        # Seconds to wait for a job to start before polling whether job status is "running".
        [int]
        $WaitInterval = 10
    )

    process
    {

        if ($RunAtTime)
        {
            $dateCodeISO8601 = Get-Date -Date $RunAtTime.ToUniversalTime() -UFormat '%Y-%m-%dT%H:%M:%S-0000'

            $body = @{ 'runAtTime' = $dateCodeISO8601 } | ConvertTo-Json
            $jobRun = Invoke-RundeckRestMethod -Method 'POST' -ResourcePath "job/$($ID)/executions" -Body $body
        }
        else
        {
            $jobRun = Invoke-RundeckRestMethod -Method 'POST' -ResourcePath "job/$($ID)/executions"
        }

        
        Start-Sleep -Seconds 1

        if ($Wait)
        {
            while ($jobRun.status -eq 'running')
            {
                Start-Sleep -Seconds $WaitInterval
                $jobRun = Get-RundeckJobExecution -Uri $jobRun.permalink
            }
        }
        return $jobRun
    }
}