Import-Module (Join-Path $PSScriptRoot -ChildPath '../../RundeckAutomation' -Resolve)
function GivenAJob
{
    param(
        [string]
        $Project,

        [switch]
        $RemoveUuid,

        [switch]
        $shouldBeDisabled
    )
    $jobName = -join ((65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object {[char]$_})
    $jobId = [guid]::NewGuid().ToString()
    $jobFilePath = New-TemporaryFile
    $jobCommand = 'dir'

    if ($shouldBeDisabled)
    {
        $scheduleStatus = 'false'
    }
    else
    {
        $scheduleStatus = 'true'
    }

    $xmlDocument = @"
    <joblist>
    <job>
      <defaultTab>nodes</defaultTab>
      <description></description>
      <executionEnabled>true</executionEnabled>
      <id>$($jobId)</id>
      <loglevel>INFO</loglevel>
      <name>$($jobName)</name>
      <nodeFilterEditable>false</nodeFilterEditable>
      <plugins />
      <schedule>
        <month month='*' />
        <time hour='00' minute='00' seconds='0' />
        <weekday day='*' />
        <year year='0/99' />
      </schedule>
      <scheduleEnabled>$($scheduleStatus)</scheduleEnabled>
      <sequence keepgoing="false" strategy="node-first">
        <command>
          <exec>$($jobCommand)</exec>
        </command>
      </sequence>
      <uuid>$($jobId)</uuid>
    </job>
  </joblist>
"@

    Set-Content -Path $jobFilePath.FullName -Value $xmlDocument -Force | Out-Null

    if ($RemoveUuid)
    {
        Import-RundeckJob -Path $jobFilePath.FullName -ProjectName $Project -RemoveUuid | Out-Null
    }
    else
    {
        Import-RundeckJob -Path $jobFilePath.FullName -ProjectName $Project | Out-Null
    }

    return @($jobName, $jobId.ToString())
}

function GivenAJobFile
{
    param(
    )
    $jobName = -join ((65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object {[char]$_})
    $jobId = [guid]::NewGuid().ToString()
    $jobFilePath = (New-TemporaryFile).FullName
    $jobCommand = 'dir'
    $scheduleStatus = 'true'

    $xmlDocument = @"
    <joblist>
    <job>
      <defaultTab>nodes</defaultTab>
      <description></description>
      <executionEnabled>true</executionEnabled>
      <id>$($jobId)</id>
      <loglevel>INFO</loglevel>
      <name>$($jobName)</name>
      <nodeFilterEditable>false</nodeFilterEditable>
      <plugins />
      <schedule>
        <month month='*' />
        <time hour='00' minute='00' seconds='0' />
        <weekday day='*' />
        <year year='0/99' />
      </schedule>
      <scheduleEnabled>$($scheduleStatus)</scheduleEnabled>
      <sequence keepgoing="false" strategy="node-first">
        <command>
          <exec>$($jobCommand)</exec>
        </command>
      </sequence>
      <uuid>$($jobId)</uuid>
    </job>
  </joblist>
"@

    Set-Content -Path $jobFilePath -Value $xmlDocument -Force | Out-Null

    return $jobFilePath
}

function GivenAProject
{
    param(
        [switch]
        $AsXml
    )

    $projectName = -join ((65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object {[char]$_})

    if ($AsXml)
    {
        $xmlDocument = @"
<project>
    <name>$($projectName)</name>
    <config>
    </config>
</project>
"@
        $projectFilePath = New-TemporaryFile
        Set-Content -Path $projectFilePath.FullName -Value $xmlDocument -Force | Out-Null
        Import-RundeckProject -File $projectFilePath.FullName | Out-Null
    }
    else
    {
        
        $jsonProjectDefinition = @{ 'name' = $projectName; 'config' = @{ } } | ConvertTo-Json
        Import-RundeckProject -Config $jsonProjectDefinition | Out-Null
    }

    return $projectName
    
}

function GivenAProjectFile
{
    param(
        [switch]
        $AsXml
    )

    $projectName = -join ((65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object {[char]$_})

    if ($AsXml)
    {
        $xmlDocument = @"
<project>
    <name>$($projectName)</name>
    <config>
    </config>
</project>
"@
        $projectFilePath = (New-TemporaryFile).FullName
        Set-Content -Path $projectFilePath -Value $xmlDocument -Force | Out-Null
        return $projectFilePath
    }
    else
    {
        
        $jsonProjectDefinition = @{ 'name' = $projectName; 'config' = @{ } } | ConvertTo-Json
        return $jsonProjectDefinition
    }

    return $projectName

}