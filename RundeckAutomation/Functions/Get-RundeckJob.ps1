function Get-RundeckJob
{
    <#
    .SYNOPSIS
    Gets a job from Rundeck.

    .DESCRIPTION
    The `Get-RundeckJob` function gets a job from Rundeck.

    .EXAMPLE
    GEt-RundeckJob -ProjectName $refProject.Name -ID 'b090d4c8-585c-4330-8bc6-ad4783089dfd'

    Demonstrates how to get a specific job usng its ID.
    #>
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='ByName')]
        [string]
        # The job's name.
        $Name,

        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='ByFilter')]
        [string]
        # The job name filter.
        $Filter,

        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='ByID')]
        [guid]
        # The job's ID.
        $ID,

        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string]
        # The project name.
        $ProjectName    
    )

    process
    {
        $allJobs = Invoke-RundeckRestMethod -Method 'GET' -ResourcePath "project/$($ProjectName)/jobs"

        if ($Name)
        {
            return ($allJobs | Where-Object { $_.name -eq $Name })
        }
        elseif ($ID)
        {
            return ($allJobs | Where-Object { $_.id -eq $ID })
        }
        else
        {
            $queryFilter = [ScriptBlock]::Create($Filter)
            return ($allJobs | Where-Object { $_.name -like $queryFilter })
        }
    }
}