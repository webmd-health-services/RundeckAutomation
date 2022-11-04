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
        # The job's name.
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='ByName')]
        [string]
        $Name,

        # The job name filter.
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='ByFilter')]
        [string]
        $Filter,

        # The job's ID.
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='ByID')]
        [guid]
        $ID,

        # The project name.
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string]
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