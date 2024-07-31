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
        # $relativeUri = "project/$($Name)/export"
        # $relativeUri = '{0}?{1}' -f $relativeUri, "exportConfigs=true&exportAll=false"
        # Write-Host $relativeUri
        # $endpointUri = New-Object 'Uri' -ArgumentList @($_RundeckSession.Uri, $relativeUri)
        # $rawRequest = Invoke-WebRequest -ErrorAction 'Stop' -WebSession $_RundeckSession.WebSession -Method 'GET' -Uri $endpointUri # -OutFile $Path
        # Write-Host ($rawRequest | ConvertTo-Json | Out-String)

        Invoke-RundeckRestMethod -BodyIsStream -OutputPath $Path -ErrorAction 'Stop' -Method 'GET' -ResourcePath "project/$($Name)/export" -QueryString "exportConfigs=true&exportAll=false"
    }
}