function New-RundeckSession
{
    <#
    .SYNOPSIS
    Creates a connection to Rundeck instance.

    .DESCRIPTION
    The `New-RundeckSession` function creates a connection to a Rundeck instance. Pass the URI to the instance to the `Uri` parameter. Pass the credentials to use to authenticate to the `Credential` parameter. 

    The function generates a token for further access to the Rundeck API using the credentials by making a request to the `/api/v2/api-token-auth` endpoint.

    .EXAMPLE
    New-RundeckSession -Uri 'https://Rundeck.example.com' -Credential $me

    Demonstrates how to connect to an instance of Rundeck. In this case, the connection is to the instance at `https://rundeck.example.com` using the credentials in the `$me` variable.
    #>
    [CmdletBinding()]
    param(
        # The URI to the Rundeck instance to connect to.
        [Parameter(Mandatory)]
        [uri]
        $Uri,

        # The credentials to use.
        [Parameter(Mandatory, ParameterSetName = 'username')]
        [pscredential]
        $Credential,

        # The credentials to use.
        [Parameter(Mandatory, ParameterSetName = 'apitoken')]
        [string]
        $ApiToken,

        # Optional specify API version.  Defaults to 41.
        [string]
        $ApiVersion = 41
    )

    Set-StrictMode -Version 'Latest'

    $apiUri = New-Object -TypeName 'Uri' -ArgumentList @($Uri,"/api/$($ApiVersion)/")

    if ($Credential)
    {
        $tokenUri = New-Object -TypeName 'Uri' -ArgumentList @($Uri,'j_security_check')
        $body = "j_username=$($Credential.UserName)&j_password=$($Credential.GetNetworkCredential().Password)"

        Write-Debug  $body

        Invoke-WebRequest -SessionVariable restSession -Method Post -Uri $tokenUri -UseBasicParsing -Body $body
        $rundeckCookies = $restSession.Cookies.GetCookies($Uri)
        Write-Debug ( $rundeckCookies | Where-Object { $_.Name -eq 'JSESSIONID' } | Format-List * | Out-String )
    }
    else
    {
        $restSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add('X-Rundeck-Auth-Token', $ApiToken)
        $restSession.Headers= $headers
    }
    
    New-Variable -Force -Name '_RundeckSession' -Scope Script -Value ([pscustomobject]@{ WebSession = $restSession; Uri = $apiUri })

}
