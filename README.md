# DacSteriLog

Powershellscript um LOG-Dateien vom DAC Universal Sterilisator auswerten zu können.

Zunächst muss man die Scripte laden, da es noch kein vollständiges Modul gibt.

## Laden

```Powershell
. .\DacSteriAnalyse.PS1
. .\DacSteriLogger.PS1
. .\DacSteriReport.PS1
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
} else {
    $e++
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
$az = $az | sort Zyklus

# sucht man davon nur bestimmte Wochentage die erfolgreich waren
$azd = $az | where {$_.Wochentag -eq "Dienstag" -and $_.Fehlerhaft -eq $false}

# sucht man einen Eintrag an einem bestimmten Wochentag der zwischen 11:30 Uhr und  17 Uhr lief:
$azd = $az | where {$_.Wochentag -eq "Dienstag" -and (NachUhrzeit $_.Beginn "11:30") -and (VorUhrzeit $_.Ende "16:59")  -and $_.Fehlerhaft -eq $false}

# zur schnelleren Analyse kann man auch PassThru verwenden:
$p=Test-DacZyklenChronologie -Zyklen $z -verbose -PassThru
$z | where Zyklus -In ($p.VonZyklus,$p.BisZyklus)| select Zyklus, Wochentag, Beginn, Ende| ft -AutoSize
# Tage mit bestimmten Kriterien zur Auswahl stellen, das ausgewählte Objekt in die Zwischenablage kopieren
$z | where {$_.Wochentag -eq "Montag" -and (NachUhrzeit $_.Beginn "16:00") -and (VorUhrzeit $_.Ende "23:30")  -and $_.Fehlerhaft -eq $false } |Out-GridView -PassThru | select -ExpandProperty rawContent | clip

# Vergleichbare Zyklen im Zeitraum zwischen den Problemzyklen ermitteln
# hier wird nur $p[0] beachtet, die weiteren Elemente sollte auch bearbeitet werden
$beginn = ($z | where Zyklus -in $p[0].VonZyklus).Ende
$ende = ($z | where Zyklus -in $p[0].BisZyklus).Beginn
$zv = $az | where {-not $_.Fehlerhaft -and (Test-BetweenWeekDays -Datum $_.Beginn -Wochenanfang $beginn -Wochenende $ende)}
# TODO: Auswahl darstellen, ein Element wählen und das Datum und die Zyklennummer anpassen

# weitere Tests durchführen mit neuem Einsprung passend zum letzten Abbruch
$e=Get-ElementFromZyklus -Zyklen $z -Zyklus $p[0].BisZyklus
$tz = $z[$e..($z.Length)]
$p=Test-DacZyklenChronologie -Zyklen $tz -Verbose -PassThru

# sollten verschiedene LOG-Dateien zusammengespielt werden, so müssen diese sortiert werden
$kombination = $z + $nz
$kombination = $kombination | sort Zyklus
Test-DACZyklenChronologie -Zyklen $kombination -Verbose -Continue

# Wenn Test-DACZyklenChronologie $true meldet, kann man die Daten im Melag speichern
# man könnte davor noch das $basePath-Verzeichnis wegkopieren
# der erste Eintrag sollte übersprungen werden, da es der letzte bereits bestehende Zyklus ist!!
$tz = $z[($e+1)..($z.Length)]
Write-DACLogFile -BasePath $basePath -Device DAC01 -Zyklus $tz -Verbose
                                                   # sollte Zyklen heißen!
```
