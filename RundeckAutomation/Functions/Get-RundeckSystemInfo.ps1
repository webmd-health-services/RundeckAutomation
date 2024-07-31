function Get-RundeckSystemInfo
{
    <#
    .SYNOPSIS
    Gets system info from Rundeck.

    .DESCRIPTION
    The `Get-RundeckSystemInfo` function gets gets the system information for a Rundeck instance.

    .EXAMPLE
    GEt-RundeckSystemInfo

    Demonstrates how to get the Rundeck system info.
    #>
    [CmdletBinding()]
    param(

    )

    process
    {
        return ( Invoke-RundeckRestMethod -Method 'GET' -ResourcePath 'system/info' )
    }
}