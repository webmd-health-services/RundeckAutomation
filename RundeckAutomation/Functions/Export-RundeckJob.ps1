function Export-RundeckJob
{
    <#
    .SYNOPSIS
    Exports a job from Rundeck to an XML file.

    .DESCRIPTION
    The `Export-RundeckJob` function exports a job from Rundeck to an XML file.

    .EXAMPLE
    Export-RundeckJob -Path '.\test.xml' -ProjectName 'demo' -ID 'b090d4c8-585c-4330-8bc6-ad4783089dfd'

    Demonstrates how to export a job defined in the demo project to an XML file called test.xml.
    #>
    param(
        # The path to an XML job definition file.
        [Parameter(Mandatory)]
        [String] $Path,

        # The project name.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [String] $ProjectName,

        # The job ID.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Guid] $ID
    )

    process
    {

        $jobExport = Invoke-RundeckRestMethod -ContentIsXML -ErrorAction 'Stop' -Method 'GET' -ResourcePath "project/$($ProjectName)/jobs/export" -QueryString "idlist=$($ID)"

        Set-Content -Value $jobExport.InnerXml -Path $Path -Force -Encoding UTF8

    }
}