#CreatePSSchedService.PS1

# damit die Sache mit dem lokalen Dienst funktioniert, muss der Dienst Zugriff auf die betreffende
# LOG-Datei erhalten!
# C:\DACSteriLog>icacls.exe SteriProtokollLogger.Log
# SteriProtokollLogger.Log NT-AUTORITÄT\Lokaler Dienst:(F)
#
# dies erreicht man durch
# icacls.exe SteriProtokollLogger.Log /grant "NT-Autorität\Lokaler Dienst:(F)" 
#
# https://msdn.microsoft.com/de-de/library/windows/desktop/ms684188(v=vs.85).aspx
#

# Log-Datei anlegen mit passenden Rechten für den Lokalen Dienst
$LogFileName = "C:\DACSteriLog\SteriProtokoll.Log" 
New-Item -Type File -Path $LogFileName
$acl = Get-Acl $LogFileName
$ar = New-Object System.Security.AccessControl.FileSystemAccessRule("NT-Autorität\Lokaler Dienst", "FullControl", "Allow")
$acl.SetAccessRule($ar)
Set-Acl $LogFileName $acl

# Zum Abfragen der aktuellen Rechte verwendet man einfach
(Get-Acl $LogFileName).Access

# ALTERNATIVE:
# möchte man die Rechte fürs Verzeichnis ändern:
$LogDir = "C:\DACSteriLog"
New-Item -ItemType Directory $LogDir
$acl = Get-Acl $LogDir
$localService = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::LocalServiceSid, $null);
$rights = [System.Security.AccessControl.FileSystemRights]::FullControl
$inheritance = [int]([System.Security.AccessControl.InheritanceFlags]::ContainerInherit) + [int]([System.Security.AccessControl.InheritanceFlags]::ObjectInherit)
$propagation = [System.Security.AccessControl.PropagationFlags]::None
$accessControl = [System.Security.AccessControl.AccessControlType]::Allow
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($localService, $rights, $inheritance, $propagation , $accessControl)
$acl.SetAccessRule($AccessRule)
Set-Acl $LogDir $acl


$ScriptToRun="C:\DACSteriLog\SteriProtokollLogger.PS1"
$TaskName = "DacSteriLog"
$TaskPath = "\MyTasks\Aufgaben" # beliebige Hierarchie möglich

$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -File $ScriptToRun"
$trigger = New-ScheduledTaskTrigger -Daily -At "06:00"
# damit LocalService die Datei schreiben darf, muss LocalService Schreibrechte bekommen!
$principal = New-ScheduledTaskPrincipal -UserId "LOCALSERVICE" -LogonType ServiceAccount #-RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew

Register-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -Action $action -Trigger $trigger -Settings $settings -Principal $principal

# Aufgabenplanung öffnen, hier kann man den angelegte Task finden
control schedtasks

# verschiedene Befehle zum Debuggen mittels Powershellbefehle bzw. Batchbefehle:
#$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -command "& {Get-Date|Add-Content -Path c:\temp\test.log}'
#Start-Process -FilePath 'c:\windows\system32\cmd.exe' -ArgumentList '/C ECHO nix >> C:\TEMP\Test.LOG'
#$action = New-ScheduledTaskAction -Execute 'c:\windows\system32\cmd.exe' -Argument '/C ECHO nix >> C:\TEMP\Test.LOG'
#$trigger = New-ScheduledTaskTrigger -Daily -At "06:00" -RepetitionInterval (New-TimeSpan -Minutes 2) -RepetitionDuration ([Timespan]::MaxValue)
#$principal = New-ScheduledTaskPrincipal -UserId "$($env:USERDOMAIN)\$($env:USERNAME)" -LogonType ServiceAccount

