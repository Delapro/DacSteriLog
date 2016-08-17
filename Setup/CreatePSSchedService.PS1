#CreatePSSchedService.PS1

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

