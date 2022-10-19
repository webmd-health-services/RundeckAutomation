function Get-RundeckJobExecution
{
    <#
    .SYNOPSIS
    Gets a job job execution status from Rundeck.

    .DESCRIPTION
    The `Get-RundeckJobExecution` function gets a job execution status from Rundeck.

    .EXAMPLE
    Get-RundeckJobExecution -ProjectName $refProject.Name -ID 'b090d4c8-585c-4330-8bc6-ad4783089dfd'

    Demonstrates how to get a specific job usng its ID.
    #>
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='ByUri')]
        [string]
        # The job's name.
        $Uri
    )

    process
    {
        $status = Invoke-RundeckRestMethod -Method 'GET' -ResourcePath $Uri
        return $status
    }
}