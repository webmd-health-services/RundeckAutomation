function Remove-RundeckProject
{
    <#
    .SYNOPSIS
    Removes a Rundeck project.

    .DESCRIPTION
    The `Remove-RundeckProject` function removes a Rundeck project.

    .EXAMPLE
    Remove-RundeckProject -Name 'demoproject'

    Demonstrates how to remove the 'demoproject' project
    #>
    [CmdletBinding()]
    param(
        # The project's name.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $Name
    )

    process
    {
        Invoke-RundeckRestMethod -Method 'DELETe' -ResourcePath "project/$($Name)"
    }
}