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
        [String] $Path,

        # The project name.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [String] $Name
    )

    process
    {
        $projectExport = Invoke-RundeckRestMethod -BodyIsXML -ErrorAction 'Stop' -Method 'GET' -ResourcePath "project/$($Name)/export" -QueryString "exportConfigs=true&exportAll=false"
        Set-Content -Value $projectExport.InnerXml -Path $Path -Force -Encoding UTF8
    }
}