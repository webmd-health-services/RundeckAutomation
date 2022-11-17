set CURDIR=%~dp0
set $RDECK_BASE=C:/Rundeck
call %CURDIR%etc\profile.bat
java %RDECK_CLI_OPTS% %RDECK_SSL_OPTS% -jar C:\rundeck\rundeck.war --skipinstall -d  >> %CURDIR%\var\log\service.log  2>&1