function Get-RundeckProject
{
    <#
    .SYNOPSIS
    Gets a project(s) from Rundeck.

    .DESCRIPTION
    The `Get-RundeckProject` function gets one or more projects from Rundeck.

    .EXAMPLE
    Get-RundeckProject -Name 'MyTestProject'

    Demonstrates how to get a specific project using its name (not its label).

    .EXAMPLE
    Get-RundeckProject -Filter '*'

    Demonstrates how to get a all projects.

    .EXAMPLE
    Get-RundeckProject -Filter '*ops*'

    Demonstrates how to get a projects matching ops.    
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='ByName')]
        [string]
        # The project's name.
        $Name,

        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='ByFilter')]
        [string]
        # The project name filter.
        $Filter
    )

    process
    {

        if ($Name)
        {
            $project = Invoke-RundeckRestMethod -Method 'GET' -ResourcePath "project/$($Name)"
            return $project
        }
        else
        {
            $allProjects = Invoke-RundeckRestMethod -Method 'GET' -ResourcePath "projects"
            $queryFilter = [ScriptBlock]::Create($Filter)
            return ($allProjects | Where-Object { $_.name -like $queryFilter })
        }
    }
}