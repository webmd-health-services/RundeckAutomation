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
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string]
        # The path to an XML job definition file.
        $Path,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string]
        # The project name.
        $ProjectName,

        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [GUID]
        # The job ID.
        $ID
    )

    process
    {

        $jobExport = Invoke-RundeckRestMethod -Method 'GET' -ResourcePath "project/$($ProjectName)/jobs/export" -QueryString "idlist=$($ID)"

        Set-Content -Value $jobExport -Path $Path -Force -Encoding UTF8

        return $jobExport
    }
}