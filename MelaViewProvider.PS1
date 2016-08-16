# Skript zur Unterstützung von MELAView
# dabei werden in einem bestimmten Verzeichnis Textdateien
# geschrieben. Die Textdateien können beliebige Texte enthalten.
#
# Für die Darstellung in MELAView sind die Dateiendungen
# entscheidend. So werden korrekte Läufe mit der Dateiendungen
# .PRO abgespeichert und fehlerhafte mit .STR.
#
# Jeder Dateiname in MELAView wird nach dem Schema GGGGGHHH.Endung.
# Wobei GGGGG für den Gerätenamen steht, z. B. DAC01 oder 601MP.
# HHH sind einfach Zahlen die hochgezählt werden und bei erreichen
# von 9 mit A-Z weitergeführt werden.

<#
.SYNOPSIS
    Erhöht einen Zeichenkettencounterwert um eins
.DESCRIPTION
    Get-NextCounter erhöht einen Zeichenkettencounter um eins. Die Anzahl
    der Stellen ist per Vorgabe auf drei Zeichen beschränkt und kann mittels
    des Parameters $Width verändert werden. 
    Das Besondere an Get-NextCounter ist die Verwendung von Zahlen und
    Buchstaben. Der Bereich umfasst 0-9 und A-Z wobei nach 9 auf A erhöht
    wird.
.PARAMETER StartCounter
    Anfangswert der hochgezählt werden soll
.PARAMETER Width
    Breite des Counterwerts
.EXAMPLE
    Get-NextCounter
    000

    Dieser Aufruf erzeugt einen Counterwert. Die Anzahl der Stellen ist 
    per Vorgabe auf drei Zeichen beschränkt.
.EXAMPLE
    Get-NextCounter -StartCounter "001"
    002

    Dieser Aufruf erhöht den übergebenen Wert.
.EXAMPLE
    Get-NextCounter -StartCounter "00Z"
    010

    Bei Z findet ein Übertrag statt. Der vorstehende Wert wird um 1 erhöht.
    Der ursprüngliche Wert wird auf 0 gesetzt.
.EXAMPLE
    Get-NextCounter -StartCounter "ZZZ"
    Overflow
    In C:\Sample\DAC\DacSteriLog\MelaViewProvider.PS1:48 Zeichen:21
    +                     Throw "Overflow"
    +                     ~~~~~~~~~~~~~~~~
    + CategoryInfo          : OperationStopped: (Overflow:String) [], RuntimeException
    + FullyQualifiedErrorId : Overflow
    
    Wenn die maximale Counterzahl erreicht wird, dann erfolgt eine Fehlermeldung.
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
#>
Function Get-NextCounter {
    [CmdletBinding()]
    Param(
        [string]$StartCounter,
        [int]$Width=3
    )

    If (-not ($StartCounter)) {
        $StartCounter = "0" * $Width
        Write-Verbose "Start mit $StartCounter"
    } else {
        $StartCounter = $StartCounter.ToUpper()
        $Pos = $StartCounter.Length -1
        while ($true) {
            $Zeichen = $StartCounter[$Pos]
            Write-Verbose "Pos: $Pos, ermitteltes Zeichen: '$Zeichen'"
            If ($Zeichen -lt "Z") {
                # alles kleiner als Z kann in der direkten Position geändert werden
                If ($Zeichen -eq "9") {
                    # Sonderfall 9 wird zu A
                    $NeuesZeichen = "A"
                } else {
                    $NeuesZeichen = [char](([int][char]$Zeichen)+1)
                }
                $StartCounter = $StartCounter.Remove($Pos, 1).Insert($Pos, $NeuesZeichen)
                Write-Verbose "Neues Zeichen: '$NeuesZeichen', neuer Counter: '$StartCounter'"
                break
            } else {
                # Überlauf, also das nächste Zeichen links vom aktuellen erhöhen
                If ($Pos -gt 0) {
                    $StartCounter = $StartCounter.Remove($Pos, 1).Insert($Pos, "0")
                    $Pos--
                } else {
                    # es gibt kein weiteres linkes Zeichen, also Ende
                    Throw "Overflow"
                }
            }         
        }
    }

    $StartCounter
}

<#
Ermittelt vom Basispfad ausgehend das neueste Monatsverzeichnis.
In diesem wird die neueste Datei ermittelt und zurückgegeben.
#>
Function Get-LastFilename {
    [CmdletBinding()]
    Param(
        [String]$BasePath
    )
    If (Test-Path $BasePath) {
        Write-Verbose "$BasePath existiert"
        $Path = Join-Path $BasePath "??_20??"
        # neuestes Datum zuerst
        $Dirs = DIR $Path | sort {Get-Date $_.Name.Replace("_",".")} -Descending
        Write-Verbose "Bei der Suche nach $Path $($Dirs.Length) Einträge gefunden"
        If ($Dirs) {
            $Path = Join-Path $BasePath $Dirs[0].Name
            Write-Verbose "neuester Pfad: $Path"
            If (Test-Path ($path)) {
                $Files = Get-ItemChild -Path "$($Path)\*" -Include *.PRO, *.STR | sort Name -Descending
                Write-Verbose "$($Files.Length) Dateien gefunden, neueste: ($Files[0].Name)"
                $Files[0]
            }
        }
    }
}

Function New-Filename {
    [CmdletBinding()]
    Param(
        [string]$BasePath,
        [string]$Counter,
        [string]$Device,
        [DateTime]$Date,
        [bool]$Successful
    )
    
    If (Test-Path $BasePath) {
        $dateDir = Get-Date $Date -Format "MM_yyyy"
        $Path = Join-Path $BasePath $dateDir
        # Monatsverzeichnis anlegen, wenn nicht vorhanden:
        If (-Not (Test-Path ($path))) {
            New-Item -Path $Path -ItemType Directory | Out-Null
        }
        If ($Successful) {
            $ext = ".PRO"
        } else {
            $ext = ".STR"
        }
        $File = Join-Path $Path "$Device$Counter$ext"
        Write-Verbose "Anzulegender Dateiname: $File"
        $FileInfo = New-Item $File
    } else {
        Throw "$BasePath ist nicht vorhanden!"
    }

    $FileInfo
}

Function Write-LogFile {
    [CmdletBinding()]
    Param(
        [string]$Filename,
        [PSTypeName("DAC.Zyklus")]$Zyklus
    )
    Write-Verbose "Schreibe $($Zyklus.Zyklus) in $Filename"
    $Zyklus.RawData | Set-Content -Path $Filename -Force -Encoding Ascii
}
