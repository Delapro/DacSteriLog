# Script zur Analyse von DAC Sterilisator LOG-Dateien
# die LOG-Datei entspricht nicht den reinen DAC-Daten sondern enthält zusätzliche Informationen,
# welche über ein Powershell Script hinzugefügt werden.
#

Function Analyze-DACLogFile {
    [CmdletBinding()]
    Param (
		[Parameter(Mandatory=$true)]
		[String]$Path,
        [Long]$Index=0
	)

    If (Test-Path $Path) {
        $Log = Get-Content $Path
        
        $Zyklen = @()

        Write-Verbose "Anzahl: $($Log.Length)"
        while ($index -lt $log.Length) {
            $DACBlock = Get-DACBlockPos $log $index
            If ($DACBlock.DACBlock) {
                $Zyklen += Analyze-DACZyklus $DACBlock.DACBlock
            }
            $Index = $DACBlock.Index
            Write-Verbose "Index: $Index Blocklength: $($Zeilen.Length)"
        }
        $Zyklen
        
    } else {
        Write-Error "LOG-Datei $Path nicht vorhanden!"
    }

}

Function Analyze-DACZyklus {
    [CmdletBinding()]
    Param (
        [String[]]$Zyklus
    )

    $DACZyklus = [PSCustomObject]@{
                    Seriennummer=$Zyklus[1].Substring(12);
                    Programm=$Zyklus[2].Substring(12);
                    Deckel=$Zyklus[3].Substring(12);
                    Zyklus=$Zyklus[4].Substring(12);
                    Datum=Get-Date "$($Zyklus[5].Substring(12)) $($Zyklus[6].Substring(11))";
                    Phasen="";
                }
    $DACZyklus.PSTypenames.Insert(0, "DACZyklus")
    $DACZyklus
}

Function Get-DACBlockPos {
    [CmdletBinding()]
    Param(
        [String[]]$Log,
        [long]$Index = 0
    )

    $start = -1
    $end = -1

    while ($Index -lt $log.Length -and $end -eq -1) {
        $Zeile = $Log[$Index]
        If ($Zeile -match "DAC Universal") {
            Write-Verbose "DAC Universal erkannt, Zeile: $Index"
            If ($Start -eq -1) {
                $start = $Index
            } else {
                $end = $Index
            }
        } else {
            If ($Zeile -match "Zyklusende" -and $Start -ne -1) {
                Write-Verbose "Zyklusende erkannt, prüfen ob kein Fehler"
                If (-not ($Zeile -match "FEHL") ) {
                    Write-Verbose "Zyklusende erkannt, Zeile: $Index"
                    If ($Start -eq -1) {
                        $start = $Index
                    } else {
                        $end = $Index
                    }
                }            
            }
        }
        $index++
    }

    If ($start -ne -1 -and $end -ne -1) {
        $DACBlock = $Log[$start..$end]
    } else {
        $DACBlock = $Null
    }

    [PSCustomObject]@{DACBlock=$DACBlock; Index=$Index}

}

Analyze-DACLogFile -Path .\DAC.LOG
