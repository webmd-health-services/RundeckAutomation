
function Invoke-RundeckRestMethod
{
    <#
    .SYNOPSIS
    Calls a method in the Rundeck REST API.

    .DESCRIPTION
    The `Invoke-RundeckRestMethod` function calls a method in the Rundeck REST API. Pass a session/connection object to the `Session` parameter (use `New-RundeckSession` to create a session object), the HTTP method to use to the `Method` parameter, the relative path to the endpoint to the `ResourcePath` parameter (i.e. everything after `api/v2/` in the endpoint's path), and the body of the request (if any) to the `Body` parameter. A result object is returned, which is different for each endpoint.

    .EXAMPLE
    Invoke-RundeckRestMethod -Method Get -ResourcePath ('orders/{0}/' -f $ID) 

    Demonstrates how to use `Invoke-RundeckRestMethod` to call an endpoint that returns a single object. In this case, a specific order.

    .EXAMPLE
    Invoke-RundeckRestMethod -Method Get -ResourcePath 'groups/'

    Demonstrates how to use `Invoke-RundeckRestMethod` to call a list endpoint. In this case, `Invoke-RundeckRestMethod` will return all groups in Rundeck.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory)]
        [Microsoft.PowerShell.Commands.WebRequestMethod]
        # The HTTP method to use for the request.
        $Method,

        [Parameter(Mandatory)]
        [string]
        # The relative path to the endpoint to request. This is the part of the URI after `api/dd/`.
        $ResourcePath,

        [string]
        # The body of the request.
        $Body,

        [string]
        # URI Parameters to pass.
        $QueryString,

        [switch]
        # Content is XML format rather than JSON.
        $ContentIsXML
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    if (-not ($_RundeckSession))
    {
        Write-Error 'No Rundeck Session defined.  Use New-RUndeckSession to log in to Rundeck.'
        exit
    }

    $relativeUri = $ResourcePath
    if( $QueryString )
    {
        $relativeUri = '{0}?{1}' -f $relativeUri,$QueryString
    }
    Write-Verbose "Base $($_RundeckSession.Uri.GetType()) $($_RundeckSession.Uri)"
    Write-Verbose "Relative $($relativeUri.GetType()) $($relativeUri)"
    $endpointUri = New-Object 'Uri' -ArgumentList @($_RundeckSession.Uri,$relativeUri)

    if ($ContentIsXML)
    {
        $contentType = 'application/xml'
        $contentAccept = 'application/xml'
    }
    else
    {
        $contentType = 'application/json'
        $contentAccept = 'application/json'
    }
    Write-Verbose "Content type $($contentType)"
    Write-Debug ($endpointUri | Format-List | Out-String)
    Write-Debug ($_RundeckSession.WebSession | Format-List * | Out-String)

    try
    {

        if( $Body )
        {
            $Body | Write-Debug
        }

        if( $Method -eq [Microsoft.PowerShell.Commands.WebRequestMethod]::Get -or $PSCmdlet.ShouldProcess($endpointUri,$Method) )
        {
            $bodyParam = @{ }
            if( $Body )
            {
                $bodyParam['Body'] = $Body
            }

            Invoke-RestMethod -WebSession $_RundeckSession.WebSession -Method $Method -Uri $endpointUri -Headers @{'Accept'=$contentAccept} -ContentType $contentType @bodyParam |
                Where-Object { $_ }
        }
    }
    catch [Net.WebException]
    {
        Write-Error -ErrorRecord $_ -ErrorAction $ErrorActionPreference
    }
}
