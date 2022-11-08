function Export-RundeckProject
{
    <#
    .SYNOPSIS
    Exports a project from Rundeck to an XML file.

    .DESCRIPTION
    The `Export-RundeckProject` function exports a project from Rundeck to an XML file.

    .EXAMPLE
    Export-RundeckProject -Path '.\test.zip' -Name 'demo'

    Demonstrates how to export a project named 'demo' to an zip file called test.zip.
    #>
    param(
        # The path to an zip project archive file.
        [Parameter(Mandatory)]
        [string]
        $Path,

        # The project name.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $Name
    )

    process
    {

        $relativeUri = "project/$($Name)/export"
        $relativeUri = '{0}?{1}' -f $relativeUri, "exportConfigs=true&exportAll=false"
        $endpointUri = New-Object 'Uri' -ArgumentList @($_RundeckSession.Uri, $relativeUri)
        Invoke-WebRequest -ErrorAction 'Stop' -WebSession $_RundeckSession.WebSession -Method 'GET' -Uri $endpointUri -OutFile $Path

    }
}