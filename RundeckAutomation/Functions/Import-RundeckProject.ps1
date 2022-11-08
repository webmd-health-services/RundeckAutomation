function Import-RundeckProject
{
    <#
    .SYNOPSIS
    Creates a Rundeck project from JSON string or XML document file.

    .DESCRIPTION
    The `Import-RundeckProject` function creates a Rundeck project from JSON string or XML document file.  See https://docs.rundeck.com/docs/api/rundeck-api.html#getting-project-info for content definition.

    .EXAMPLE
    $jsonProjectDefinition = '{ "name": "myproject", "config": { "propname":"propvalue" } }'
    Import-RundeckProject -Config $jsonProjectDefinition

    Demonstrates how to create a project using a JSON string.

    .EXAMPLE
    Import-RundeckProject -File '~/xmlProjectDefinition.xml'

    Demonstrates how to create a project using a XML document file.
    #>
    [CmdletBinding()]
    param(
        # The project's configuration in JSON format.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName='ByJson')]
        [string]
        $Config,

        # The project's configuration as a XML Document.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName='ByFile')]
        [string]
        $File
    )

    process
    {

        $resourcePath = 'projects'
        $method = 'POST'
        if ($File)
        {
            Invoke-RundeckRestMethod -Method $method -ResourcePath $resourcePath -Body (Get-Content -Raw -Path $File) -ContentIsXML
        }
        else
        {
            Invoke-RundeckRestMethod -Method $method -ResourcePath $resourcePath -Body $Config
        }
    }
}