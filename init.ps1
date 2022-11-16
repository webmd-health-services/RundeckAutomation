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

$rundeckVersion = '4.6.1-20220914'
$openJdkVersion = '11.0.16.1'
$rundeckWarUri = "https://packagecloud.io/pagerduty/rundeck/packages/java/org.rundeck/rundeck-$($rundeckVersion).war/artifacts/rundeck-$($rundeckVersion).war/download"

if (($PSVersionTable.PSEdition -eq 'Desktop') -or ($PSVersionTable.Platform -eq 'Win32NT'))
{    
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
            $javaPath = Get-ChildItem -Recurse -Force -ErrorAction Ignore -Path 'C:\Program Files\Microsoft' -Filter 'java.exe' | Where-Object { $_.FullName -match $openJdkVersion } | Select-Object -ExpandProperty FullName
            if ($javaPath.GetType().Name -ne 'String')
            {
                $javaVersion = Start-InstallProcess -ExecutablePath $javaPath -ExecutableParameters @('-version')
                Write-Host $javaVersion.stderr
                Write-Host 'Installed OpenJDK'
            }
            else
            {
                Write-Verbose "`n`nJAVA PATHS::`n$($javaPath | Format-List * | Out-String))::`n`n"
                Write-Warning "Wrong number of java runtimes found."
            }
        }
    }
    else
    {
        Write-Error "$($msiPath) missing."
    }

    Write-Host 'Install Rundeck'
    Invoke-WebRequest -UseBasicParsing -Uri $rundeckWarUri -OutFile $rundeckWarFile
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

    try
    {
        New-NetFirewallRule -Name 'Allow Rundeck' -DisplayName 'Allow Rundeck' -Enabled True -Profile Any -Direction Inbound -Action Allow -LocalPort 4440 -Protocol 'TCP'
    }
    catch
    {
        netsh advfirewall firewall add rule name="Allow Rundeck" dir=in action=allow protocol=TCP localport=4440
    }

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
}
else
{
    & whoami
    Write-Host '------------------------------------------------------'
    Write-Host (Get-ChildItem ENV: | Format-Table -Wrap | Out-String)
    Write-Host '------------------------------------------------------'
    Write-Host (Get-Variable | Format-Table -Wrap | Out-String)
    Write-Host '------------------------------------------------------'

    $rundeckPath = '/opt/rundeck'
    $rundeckWarFile = Join-Path -Path $rundeckPath -ChildPath 'rundeck.war'
    $rundeckConfigPath = Join-Path -Path $rundeckPath -ChildPath 'server\config\rundeck-config.properties'

    if ($isLinux)
    {
        $javaPath = '/usr/lib/jvm/java-11-openjdk-amd64/bin/java'
    }
    elseif ($IsMacOS)
    {
        $javaPath = '/System/Volumes/Data/Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home/bin/java'
    }

    $javaVersion = Start-InstallProcess -ExecutablePath $javaPath -ExecutableParameters @('-version')
    Write-Host $javaVersion.stderr
    Write-Host 'Installed OpenJDK'

    New-Item -ItemType Directory -Name $rundeckPath
    sudo chown (& whoami) $rundeckPath 

    Invoke-WebRequest -UseBasicParsing -Uri $rundeckWarUri -OutFile $rundeckWarFile
    Push-Location $rundeckPath
    sudo java -jar $rundeckWarFile --installonly
    Pop-Location
    (Get-Content -Path $rundeckConfigPath) -replace 'server\.address=localhost', 'server.address=0.0.0.0' | Set-Content -Path $rundeckConfigPath -Encoding UTF8

    if ($isLinux)
    {
        $serviceFile = @"
[Unit]
Description=Rundeck
After=syslog.target network.target

[Service]
SuccessExitStatus=143

Type=simple

Environment="JAVA_HOME=/path/to/jvmdir"
Environment="RDECK_BASE=/opt/rundeck"
WorkingDirectory=/opt/rundeck
ExecStart=$($javaPath) -jar $($rundeckWarFile)
ExecStop=/bin/kill -15 `$MAINPID

[Install]
WantedBy=multi-user.target
"@
        $serviceFile
        Set-Content -Encoding UTF8 -Value $serviceFile -Path '/etc/systemd/system/rundeck.service'
        sudo systemctl enable rundeck.service
        sudo systemctl start rundeck.service
    }
    elseif ($IsMacOS)
    {
        $plistFile = @"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Label</key>
        <string>rundeck</string>
        <key>ServiceDescription</key>
        <string>rundeck</string>
        <key>ProgramArguments</key>
        <array>             
            <string>$($javaPath)</string>
            <string>-jar</string>
            <string>$($rundeckWarFile)</string>
        </array>
        <key>RunAtLoad</key>
        <false/>
    </dict>
</plist>
"@
        $plistFile
        Set-Content -Path /Library/LaunchDaemons/rundeck.plist -Value $plistFile -Encoding UTF8
        launchctl load /Library/LaunchDaemons/rundeck.plist
        launchctl start rundeck
    }
}

Start-Sleep -Seconds 5
$maxTries = 10
$i = 0

try
{
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
catch
{
    Write-Host '------------------------------------------------------'
    Write-Host ($PSVersionTable | Format-Table -Wrap | Out-String)
    Write-Host '------------------------------------------------------'
    Start-Sleep -Seconds 300
}

Write-Host 'Done with init.ps1 script'
