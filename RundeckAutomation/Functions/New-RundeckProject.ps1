function New-RundeckProject
{
    <#
    .SYNOPSIS
    Creates a Rundeck project from JSON string or XML document file.

    .DESCRIPTION
    The `New-RundeckProject` function creates a Rundeck project from JSON string or XML document file.  See https://docs.rundeck.com/docs/api/rundeck-api.html#getting-project-info for content definition.

    .EXAMPLE
    $jsonProjectDefinition = '{ "name": "myproject", "config": { "propname":"propvalue" } }'
    New-RundeckProject -Config $jsonProjectDefinition

    Demonstrates how to create a project using a JSON string.

    .EXAMPLE
    New-RundeckProject -File '~/xmlProjectDefinition.xml'

    Demonstrates how to create a project using a XML document file.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='ByJson')]
        [string]
        # The project's configuration in JSON format.
        $Config,

        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='ByFile')]
        [string]
        # The project's configuration as a XML Document.
        $File
    )

    process
    {

        $resourcePath = 'projects'
        $method = 'POST'
        if ($File)
        {
            Invoke-RundeckRestMethod -Method $method -ResourcePath $resourcePath -Body (Get-Content -Raw -File $File) -ContentIsXML
        }
        else
        {
            Invoke-RundeckRestMethod -Method $method -ResourcePath $resourcePath -Body $Config
        }
    }
}