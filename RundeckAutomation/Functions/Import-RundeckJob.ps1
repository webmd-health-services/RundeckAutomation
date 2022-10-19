function Import-RundeckJob
{
    <#
    .SYNOPSIS
    Imports a job to Rundeck from an XML file.

    .DESCRIPTION
    The `Import-RundeckJob` function starts a job from Rundeck.

    .EXAMPLE
    Import-RundeckJob -Path '.\test.xml' -ProjectName 'demo'

    Demonstrates how to import a job defined in test.xml into the demo project.
    #>
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string]
        # The path to an XML job definition file.
        $Path,

        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string]
        # The project name.
        $ProjectName,

        [switch]
        # Do not preserve the UUID for the job when importing.
        $RemoveUuid
    )

    process
    {
        $jobDefinition = Get-Content -Raw -Path $Path

        if ($RemoveUuid)
        {
            $jobQuery = 'uuidOption=remove'
        }

        $jobImport = Invoke-RundeckRestMethod -QueryString $jobQuery -Body $jobDefinition -Method 'POST' -ResourcePath "project/$($ProjectName)/jobs/import" -ContentIsXML

        return $jobImport

    }
}