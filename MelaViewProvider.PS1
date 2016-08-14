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

Function Get-NextCounter {
    [CmdletBinding()]
    Param(
        [string]$StartCounter,
        [int]$Width=3
    )

    If (-not ($StartCounter)) {
        $StartCounter = "0" * $Width
        Write-Verbose "Start mit $StartCounter"
    }

    $Pos = $StartCounter.Length -1
    while ($true) {
        $Zeichen = $StartCounter[$Pos]
        Write-Verbose "Pos: $Pos, ermitteltes Zeichen: '$Zeichen'"
        If ($Zeichen -lt "Z") {
            If ($Zeichen -eq "9") {
                $NeuesZeichen = "A"
            } elseif ($Zeichen -eq "0") {
                $NeuesZeichen = "1"
            } else {
                $NeuesZeichen = [char](([int]$Zeichen)+1)
            }
            $StartCounter = $StartCounter.Remove($Pos, 1).Insert($Pos, $NeuesZeichen)
            Write-Verbose "Neues Zeichen: '$NeuesZeichen', neuer Counter: '$StartCounter'"
            break
        } else {
            # Überlauf
            If ($Pos -gt 0) {
                $StartCounter = $StartCounter.Remove($Pos, 1).Insert($Pos, "0")
                $Pos--
            } else {
                Throw "Overflow"
            }
        }         
    }

    $StartCounter
}