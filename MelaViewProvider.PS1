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