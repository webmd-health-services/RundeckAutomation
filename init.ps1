<#
.SYNOPSIS
Gets your computer ready to develop the RundeckAutomation module.

.DESCRIPTION
The init.ps1 script makes the configuraion changes necessary to get your computer ready to develop for the
RundeckAutomation module. It:

.EXAMPLE
.\init.ps1

Demonstrates how to call this script.
#>
[CmdletBinding()]
param(
)

function Start-InstallProcess
{
    param(
        [string]$ExecutablePath,
        [string[]]$ExecutableParameters
    )

    $installProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
    $installProcessInfo.FileName = $ExecutablePath
    $installProcessInfo.RedirectStandardError = $true
    $installProcessInfo.RedirectStandardOutput = $true
    $installProcessInfo.UseShellExecute = $false
    $installProcessInfo.Arguments = ($ExecutableParameters -Join ' ')
    $installProcess = New-Object System.Diagnostics.Process
    $installProcess.StartInfo = $installProcessInfo
    $installProcess.Start() | Out-Null
    $installProcess.WaitForExit()
    $stdout = $installProcess.StandardOutput.ReadToEnd()
    $stderr = $installProcess.StandardError.ReadToEnd()

    return @{stdout = $stdout; stderr = $stderr}
}

Set-StrictMode -Version 'Latest'
$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'
$VerbosePreference = 'Continue'

Write-Host 'Starting init.ps1 script'

Write-Host ''
Write-Host ($PSVersionTable | Format-Table -Wrap | Out-String)
Write-Host (Get-ChildItem ENV: | Format-Table -Wrap | Out-String)
Write-Host (Get-Variable | Format-Table -Wrap | Out-String)
Write-Host ''

$rundeckVersion = '4.6.1-20220914'

if ($PSVersionTable.PSEdition -eq 'Desktop')
{
    $openJdkVersion = '11.0.16.1'
    $nssmVersion = '2.24'
    $rundeckPath = 'C:\rundeck'
    $rundeckWarFile = Join-Path -Path $rundeckPath -ChildPath 'rundeck.war'
    $msiPath = Join-Path -Path $rundeckPath -ChildPath 'openjdk.msi'
    $msiLogPath = Join-Path -Path $rundeckPath -ChildPath 'openjdk.log'
    $zipPath = Join-Path -Path $rundeckPath -ChildPath 'nssm.zip'
    $nssmPath = Join-Path -Path $rundeckPath -ChildPath 'nssm.exe'
    $rundeckConfigPath = Join-Path -Path $rundeckPath -ChildPath 'server\config\rundeck-config.properties'

    New-Item -ItemType Directory -Path $rundeckPath

    Write-Host 'Install OpenJDK'
    Invoke-WebRequest -UseBasicParsing -Uri "https://aka.ms/download-jdk/microsoft-jdk-$($openJdkVersion)-windows-x64.msi" -OutFile $msiPath -MaximumRedirection 10
    if (Test-Path $msiPath)
    {
        $msiParameters=@("/qn", "/l*", $msiLogPath, "/i", $msiPath)
        $msiExitCode = (Start-Process -FilePath msiexec.exe -ArgumentList $msiParameters -Wait -Passthru).ExitCode
        if ($msiExitCode -ne 0)
        {
            Get-Content -Path $msiLogPath
            Write-Error "MSIExec failed $($msiExitCode)."
        }
        else
        {
            $javaPath = Get-ChildItem -Recurse -Force -ErrorAction Ignore -Path 'C:\Program Files\Microsoft' -Filter 'java.exe' | Select-Object -ExpandProperty FullName
            if ($javaPath.GetType().Name -eq 'String')
            {
                $javaVersion = Start-InstallProcess -ExecutablePath $javaPath -ExecutableParameters @('-version')
                Write-Host $javaVersion.stderr
                Write-Host 'Installed OpenJDK'
            }
            else
            {
                Write-Verbose "`n`nJAVA PATHS::`n$($javaPath | Format-List * | Out-String))::`n`n"
                Write-Error "Wrong number of java runtimes found."
            }
            
        }
    }
    else
    {
        Write-Error "$($msiPath) missing."
    }

    Write-Host 'Install Rundeck'
    Invoke-WebRequest -UseBasicParsing -Uri "https://packagecloud.io/pagerduty/rundeck/packages/java/org.rundeck/rundeck-$($rundeckVersion).war/artifacts/rundeck-$($rundeckVersion).war/download" -OutFile $rundeckWarFile
    [System.Environment]::SetEnvironmentVariable('RDECK_BASE', $rundeckPath)
    $rundeckInstall = Start-InstallProcess -ExecutablePath $javaPath -ExecutableParameters @('-jar', $rundeckWarFile, '--installonly')
    Write-Host $rundeckInstall.stdout
    if ($rundeckInstall.stderr)
    {
        Write-Host $rundeckInstall.stderr
        Write-Error "Rundeck installation failed"
    }
    Copy-Item -Path (Join-Path -Path $($PSScriptRoot) -ChildPath 'vagrant\start_rundeck.bat') -Destination 'C:\rundeck\start_rundeck.bat'
    New-Item -ItemType Directory -Path (Join-Path -Path $rundeckPath -ChildPath '\var\log')
    Copy-Item -Path $rundeckConfigPath -Destination "$($rundeckConfigPath).orig"
    (Get-Content -Path $rundeckConfigPath) -replace 'server\.address=localhost', 'server.address=0.0.0.0' | Set-Content -Path $rundeckConfigPath -Encoding UTF8
    New-NetFirewallRule -Name 'Allow Rundeck' -DisplayName 'Allow Rundeck' -Enabled True -Profile Any -Direction Inbound -Action Allow -LocalPort 4440 -Protocol 'TCP'

    Write-Host 'Install Rundeck NSSM Windows service'
    Invoke-WebRequest -UseBasicParsing -Uri "http://nssm.cc/release/nssm-$($nssmVersion).zip" -OutFile $zipPath
    Expand-Archive -Path $zipPath -DestinationPath $rundeckPath
    $nssmPath = Get-ChildItem -Recurse -Force -ErrorAction Ignore -Path $rundeckPath -Filter 'nssm.exe' | Where-Object { $_.FullName -match 'win64' } | Select-Object -ExpandProperty FullName
    if ($nssmPath.GetType().Name -eq 'String')
    {
        $nssmInstall = Start-InstallProcess -ExecutablePath $nssmPath -ExecutableParameters @('install', 'RUNDECK', 'C:\Rundeck\start_rundeck.bat')
        Write-Host $nssmInstall.stdout
        if ($nssmInstall.stderr)
        {
            Write-Host $nssmInstall.stderr
            Write-Error 'NSSM failed to install.'
        }
        $nssmInstall = Start-InstallProcess -ExecutablePath $nssmPath -ExecutableParameters @('set', 'RUNDECK', 'AppDirectory', $rundeckPath)
        Write-Host $nssmInstall.stdout
        if ($nssmInstall.stderr)
        {
            Write-Host $nssmInstall.stderr
            Write-Error 'NSSM failed to install.'
        }
        Write-Host 'Installed NSSM and service'
    }
    else
    {
        Write-Error "Wrong number of nssm runtimes found."
    }
    $rundeckAccessList = Get-ACL -Path $rundeckPath
    $rundeckAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule('NT AUTHORITY\LOCAL SERVICE', 'Modify', 'ContainerInherit,ObjectInherit', 'None', 'Allow')
    $rundeckAccessList.SetAccessRule($rundeckAccessRule)
    $rundeckAccessList | Set-Acl -Path $rundeckPath

    Write-Host 'Install done.  Starting Service.'
    Start-Service -Name 'RUNDECK'
    Start-Sleep -Seconds 5
    $maxTries = 10
    $i = 0
    while ((-not (Test-NetConnection -ComputerName localhost -Port 4440).TcpTestSucceeded) -and ($i -lt $maxTries))
    {
        Write-Host 'Waiting 30 seconds for site to start...'
        Start-Sleep -Seconds 30
        ++$i  
    }

    Start-Sleep -Seconds 30

    while (((Invoke-WebRequest -ErrorAction SilentlyContinue -UseBasicParsing -Uri 'http://localhost:4440').Content -notmatch 'Rundeck - Login' ) -and ($i -lt $maxTries))
    {
        Write-Host 'Waiting 30 seconds for site to fully initialize...'
        Start-Sleep -Seconds 30
        ++$i
    }

}
else
{
    if ($IsMacOS)
    {
        Write-Host 'Installing Docker.'
        # Invoke-WebRequest -UseBasicParsing -Uri https://raw.githubusercontent.com/Homebrew/install/master/install.sh -OutFile /tmp/install.sh
        # chmod +x /tmp/install.sh
        # /bin/bash /tmp/install.sh
        # brew install docker
        Invoke-WebRequest -UseBasicParsing -Uri https://desktop.docker.com/mac/main/amd64/Docker.dmg?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-mac-amd64 -OutFile /tmp/Docker.dmg
        sudo hdiutil attach /tmp/Docker.dmg
        sudo /Volumes/Docker/Docker.app/Contents/MacOS/install
        sudo hdiutil detach /Volumes/Docker
    }

    try
    {
        & docker pull rundeck/rundeck:4.6.1-20220914
    }
    catch
    {
        Write-Host $_.Exception
        Write-Host $LASTEXITCODE
    }

    try
    {
        & docker run -d -p 4440:4440 rundeck/rundeck:4.6.1-20220914
    }
    catch
    {
        Write-Host $_.Exception
        Write-Host $LASTEXITCODE
    }

    $maxTries = 10
    $i = 0
    if ($IsWindows)
    {
        while ((-not (Test-NetConnection -ComputerName localhost -Port 4440).TcpTestSucceeded) -and ($i -lt $maxTries))
        {
        Write-Host 'Waiting 30 seconds for site to start...'
        Start-Sleep -Seconds 30
        ++$i  
        }
    }
    elseif ($IsMacOS)
    {
        $output = & netstat -anp tcp | Select-String 'LISTEN' | Select-String '4440'
        while (-not ( $output))
        {
            Write-Host 'Waiting 30 seconds for site to start...'
            Start-Sleep -Seconds 30
            $output = & netstat -anp tcp | Select-String 'LISTEN' | Select-String '4440'
            ++$i  
        }
    }
    else
    {
        $output = & netstat -tulpn | Select-String 'LISTEN' | Select-String '4440'
        while (-not ( $output))
        {
            Write-Host 'Waiting 30 seconds for site to start...'
            Start-Sleep -Seconds 30
            $output = & netstat -tulpn | Select-String 'LISTEN' | Select-String '4440'
            ++$i  
        }        
    }
    Start-Sleep -Seconds 120

}

Write-Host 'Done with init.ps1 script'
