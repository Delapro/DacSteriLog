# DacSteriLog

Powershellscript um LOG-Dateien vom DAC Universal Sterilisator auswerten zu können.

Zunächst muss man die Scripte laden, da es noch kein vollständiges Modul gibt.

## Laden

```Powershell
. .\DacSteriAnalyse.PS1
. .\DacSteriLogger.PS1
. .\Fehlernummern.PS1
. .\MelaViewProvider.PS1
# zur Diagnose bestehender LOG-Dateien
. .\Util\Check.PS1
```

## Anwendung

Vorgehensweise um die neuesten Daten aus der LOG-Datei im MelaView Programm einzupflegen:

```Powershell
# zuerst den letzten gespeicherten Zyklus ermitteln:
$basePath = "C:\Melag\AutoClav\DAC01"
$lf = Get-LastFilename -BasePath $basePath
$lz = Analyze-DacLogFile -Path $lf.Fullname
$lz.Zyklus

# letzte Log-Datei einlesen
$logFile = "C:\Temp\SteriProtokoll.Log"
$z = Analyze-DacLogFile -Path $logFile

# Test auf Fehler
Test-DacZyklenChronologie -Zyklen $z[$lz.Zyklus..-1] -verbose

# Element des letzten Zyklus in der Logdatei ermitteln
$e = Get-ElementFromZyklus -Zyklen $z -Zyklus $lz.Zyklus
If ($e -eq -1) {
    # Sonderfall, die Zyklennummer des letzten Zyklus befindet sich nicht in der LOG-Datei, also am einfachsten den ersten Eintrag des Zyklus verwenden
    $e=0
}

# neues Array mit den zu testenden Zyklen erstellen und auf Konsistenz prüfen
$tz = $z[$e..($z.length)]
Test-DacZyklenChronologie -Zyklen $tz -verbose -Continue

# finden sich Ungereimheiten, dann sollten diese nun abgeklärt werden
# übersprungene Zyklen müssen bei der Weiterberechnung immer beachtet werden

# Fehlerhafte Zyklen ermitteln
$tz | where Fehlerhaft -eq $true | fl Beginn, Zyklus

# bestehende LOG-Dateien einlesen
$az = Get-AllZyklen $basePath

# zur Sicherheit sollten die Zyklen sortiert werden
$az = $az | sort Zyklen

# sucht man davon nur bestimmte Wochentage die erfolgreich waren
$azd = $az | where {$_.Wochentag -eq "Dienstag" -and $_Fehlerhaft -eq $false}

# sollten verschiedene LOG-Dateien zusammengespielt werden, so müssen diese sortiert werden
$kombination = $z + $nz
$kombination = $kombination | sort Zyklus
Test-DACZyklenChronologie -Zyklen $kombination -Verbose -Continue

# Wenn Test-DACZyklenChronologie $true meldet, kann man die Daten im Melag speichern
# man könnte davor noch das $basePath-Verzeichnis wegkopieren
Write-DACLogFile -BasePath $basePath -Device DAC01 -Zyklen $kz -Verbose

```
