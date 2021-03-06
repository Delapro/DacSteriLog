# DacSteriLog

Powershellscript um LOG-Dateien vom DAC Universal Sterilisator auswerten zu können.

Zunächst muss man die Scripte laden, da es noch kein vollständiges Modul gibt.

## Laden

```Powershell
. .\DacSteriAnalyse.PS1
. .\DacSteriLogger.PS1
. .\DacSteriReport.PS1
. .\DacSteriManipulate.PS1
. .\MelaViewProvider.PS1
# Fehlernummern per UTF-8 Encoding laden
$ExecutionContext.InvokeCommand.InvokeScript($false,([scriptblock]::Create([system.io.file]::ReadAllText((Join-Path (Resolve-Path .) ".\Fehlernummern.PS1"),[System.Text.Encoding]::UTF8))),$null,$null)
# zur Diagnose bestehender LOG-Dateien
. .\Util\Check.PS1
. .\Util\Edit.PS1
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

# um nach bestimmten Tagen mit einer bestimmten Anzahl von Zyklen suchen zu können, gruppiert
# man diese, dazu muss aber das Datum von der Uhrzeiten extra gelöst werden:
$azg = $az | Select @{N="Datum";E={(Get-Date $_.Beginn).Date}}, * | group Datum
# dann sucht man die Tage mit der gewünschten Anzahl von Zyklen und dem gewünschten Wochentag
# hier 3 Zyklen und Montag
$raz = $azg | where Count -eq 3 | where {($_.Group).Wochentag -eq "Montag"}
# nun sollte man sich für einen Eintrag entscheiden
$razr = $raz | select @{N="Von";E={($_.Group)[0].Beginn}}, @{N="Bis";E={($_.Group)[-1].Ende}}, * | out-gridView -PassThru

# um einen Zyklus zu klonen mit gleichzeitiger Manipulation gängiger Werte:
# werden die New-Parameter nicht angegeben, wird der Zyklus direkt geklont
$zn = Clone-DACZyklus -Zyklus $z[0] -NewDate (Get-Date) -NewZyklus 9999 -NewSerialNumber 632547

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


# noch ein weiterer Sonderfall, man hat eine Liste von Zyklennummern und Daten aus einer 
# CSV-Datei, woraus nun komplette Zyklen nachgebaut werden sollen
# Struktur der CSV: Nummer, Datum, Uhrzeit, Fehler
# neue Struktur der CSV: Nummer, Datum, AbUhrzeit, BisUhrzeit, Fehler
# Uhrzeit und Fehler sollten als Spalten definiert sein, werden aber momentan noch nicht beachtet!
$fehl=Import-Csv '.\VorgabeZyklenMitDatum.csv' -Delimiter ';'
# Datumfeld muss von String in DateTime gewandelt werden
$fehl = $fehl| select Nummer, @{N='Datum';E={Get-Date ($_.Datum)}}, Uhrzeit, Fehler
# $fehl = $fehl| select Nummer, @{N='Datum';E={Get-Date ($_.Datum)}}, AbUhrzeit, BisUhrzeit, Fehler
# wenn leere Felder vorhanden sind, diese ignorieren
Skip 1 für leere Felder, muss nicht sein, wenn CSV-Datei komplett ausgefüllt ist
$fehlg = $fehl| sort nummer | group Datum| select -skip 1
# für bestimmte Aktionen macht es Sinn die gruppierten Zyklen nach Zyklen pro Tag abzulegen
$azg1 = $azg | where Count -eq 1
$azg2 = $azg | where Count -eq 2
$azg3 = $azg | where Count -eq 3
$azg4 = $azg | where Count -eq 4
$azg5 = $azg | where Count -eq 5
$fehlNeu = $fehlg | % {$RZyklen = $null; switch ($_.Count) {
        1   {$RZyklen = ($azg1 | Get-Random).Group}
        2   {$RZyklen = ($azg2 | Get-Random).Group}
        3   {$RZyklen = ($azg3 | Get-Random).Group}
        4   {$RZyklen = ($azg4 | Get-Random).Group}
        5   {$RZyklen = ($azg5 | Get-Random).Group}
        default {Write-Error 'nicht definiert! Bitte $azgX definieren'}
    }
    If ($RZyklen.Count -gt 0) {
        Clone-DacZyklen -Zyklen $RZyklen -NewDate $_.Group[0].Datum -NewZyklus $_.Group[0].Nummer
    } else {
        Clone-DacZyklus -Zyklus $RZyklen -NewDate $_.Group[0].Datum -NewZyklus $_.Group[0].Nummer
    }
}
# an diesem Punkt kann man nochmal einen Quercheck machen
Test-DACZyklenChronologie $fehlNeu -Continue -Verbose
# was obigen Routinen noch fehlt sind Ab/Bis Uhrzeiten, dadurch gibt es manchmal Überscheidungen
# welche Datumsinkonsistenzfehler nach sich ziehen können, der beste Weg diese momentan zu beheben, ist,
# die erzeugten Daten in eine LOG-Datei zu schreiben und diese manuell zu bearbeiten.
# ($fehlneu).RawContent | Send-Content Fehlerhaft.log
# ebenso fehlt noch die Unterstüzung der Fehlerursachen!

# um einen Eintrag zu klonen und in der Windowszwischenablage in RawFormat zur Verfügung stellen:
Clone-DACZyklus -Zyklus $azd[0] -NewDate (Get-Date 15.10.2018) | select -ExpandProperty rawcontent | clip
```

## einen fehlenden Zyklus ausgleichen

```Powershell
$az = Get-AllZyklen $basePath
$az = $az | sort Zyklus

$azd = $az | where {$_.Wochentag -eq "Donnerstag" -and (NachUhrzeit $_.Beginn "14:30") -and (VorUhrzeit $_.Ende "19:00")  -and $_.Fehlerhaft -eq $false}

# einen Treffer rauspicken
$zz=$azd|Get-Random

$fehlneu =Clone-DACZyklus $zz -NewDate (get-Date 15.10.2020) -NewZyklus 1987
Test-DACZyklenChronologie $fehlNeu -Continue -Verbose

# ein einzelner Zyklus muss in Array konvertiert werden!
Write-DACLogFile -BasePath $basePath -Device DAC01 -Zyklus @($fehlneu) -Verbose

# nochmal Testen
# bestehende LOG-Dateien einlesen
$az = Get-AllZyklen $basePath

# zur Sicherheit sollten die Zyklen sortiert werden
$az = $az | sort Zyklus

Test-DacZyklenChronologie -Zyklen $az -verbose -Continue

# WICHTIG: fehlender Zyklus sollte in SteriProtokolloger abgespeichert werden!!
($fehlneu).RawContent | clip

```

## mehrere fehlende Zyklen ausgleichen
```Powershell
$az = Get-AllZyklen $basePath
# zur Sicherheit sollten die Zyklen sortiert werden
$az = $az | sort Zyklus
$azg = $az | Select @{N="Datum";E={(Get-Date $_.Beginn).Date}}, * | group Datum
# prüfen, ob es passt:
$azg4 = $azg | where Count -eq 4 | where {NachUhrzeit $_.Group[0].Beginn "10:50"}| where {$_.Group[0].Fehlerhaft -eq $false}
$azg4.Length
$RZyklen = ($azg4 | Get-Random).Group

# Sichtprüfung, ob es passt
$RZyklen|Out-GridView

# es wird nur das Datum und der Startzyklus angegeben
$fehlNeu = Clone-DacZyklen -Zyklen $RZyklen -NewDate (Get-Date 29.10.2020) -NewZyklus 2012
$fehlNeu|Out-GridView
Test-DACZyklenChronologie $fehlNeu -Continue -Verbose
Write-DACLogFile -BasePath $basePath -Device DAC01 -Zyklus $fehlNeu -Verbose

# nochmal Gegencheck
$az = Get-AllZyklen $basePath
# zur Sicherheit sollten die Zyklen sortiert werden
$az = $az | sort Zyklus
Test-DacZyklenChronologie -Zyklen $az -verbose -Continue

# wichtig!!
# die fehlenden Zyklen müssen noch in SteriProtokolllogger.log-Datei eingefügt werden!
($fehlneu).RawContent | clip

```

## Fehlercodes

```Powershell
# Fehlerbeschreibungen korrekt einlesen, wegen Umlauten
$ExecutionContext.InvokeCommand.InvokeScript($false,([scriptblock]::Create([system.io.file]::ReadAllText((Join-Path (Resolve-Path .) ".\Fehlernummern.PS1"),[System.Text.Encoding]::UTF8))),$null,$null)

# Fehlerbeschreibung zu einem Fehlercode ermitteln
$FehlerBeschreibungen|where CodeNr -eq 86|select Beschreibung | ft -Wrap

```

## Statistik

```Powershell
# fehlerhafte Zyklen entfernen
$azff = $az | where fehlerhaft -eq $false

# Dauer des längsten und kürzesten Zyklus ermitteln
$azff|measure -Minimum -Maximum -Property Dauer

# Zeitpunkt des frühesten und spätesten Start ermitteln
$mm = $azff|select @{N='Startzeit';E={$_.Beginn.TimeOfDay}}| measure -Minimum -Maximum -Property Startzeit
$mm
# möchte man dazu den passenden Zyklus ermitteln:
$azff|where {$_.Beginn.TimeOfDay -eq $mm.Minimum}
$azff|where {$_.Beginn.TimeOfDay -eq $mm.Maximum}
# oder manuell:
$azff|where {$_.Beginn.TimeOfDay -eq [TimeSpan]'10:13:00'}

# Zeitpunkt des frühesten und spätesten Ende ermitteln
$mm=$azff|select @{N='Endzeit';E={$_.Ende.TimeOfDay}}| measure -Minimum -Maximum -Property Endzeit
$mm
# möchte man dazu den passenden Zyklus ermitteln:
$azff|where {$_.Beginn.TimeOfDay -eq $mm.Minimum}
$azff|where {$_.Beginn.TimeOfDay -eq $mm.Maximum}
# oder manuell:
$azff|where {$_.Ende.TimeOfDay -eq [TimeSpan]'10:13:00'}

# Maschinenlaufzeiten ermitteln 
$av=$azff|select @{N='DauerTS';E={$_.Dauer.TotalSeconds}}| measure -Minimum -Maximum -average -Sum -Property DauerTS
$av
function Ts2Time ($TotalSeconds) {[TimeSpan]::New($TotalSeconds*1000*10000).toString()}
# durchschnittliche Laufzeit pro Zyklus
Ts2Time $av.Average
# schnellste Laufzeit
Ts2Time $av.Minimum
# längste Laufzeit
Ts2Time $av.Maximum
# Laufzeit insgesamt
Ts2Time $av.Sum

```
