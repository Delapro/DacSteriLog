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

Function Test-DACZyklenChronologie {
    [CmdletBinding()]
    Param (
        [PSTypeName('DAC.Zyklus')]$Zyklen
    )
    
    $Chronologisch = $True

    If ($Zyklen.Count -gt 1) {
        $TestZyklus = $Zyklen[0].Zyklus
        Write-Verbose "Startzyklus: $TestZyklus"
        for ($i = 1; $i -lt $Zyklen.Count; $i++) {
            $NaechsterZyklus = $Zyklen[$i].Zyklus
            If (($TestZyklus +1) -ne $NaechsterZyklus ) {
                Write-Verbose "unerlaubter Zyklensprung von $($NaechsterZyklus - $TestZyklus) Zyklen: $TestZyklus auf $NaechsterZyklus"
                $Chronologisch = $False
                break
            }
            $TestZyklus = $NaechsterZyklus
        }
    }

    $Chronologisch
}

Function Analyze-DACZyklus {
    [CmdletBinding()]
    Param (
        [String[]]$Zyklus
    )

    # Prüfen ob Zyklusende ordentlich da steht
    # Beispiel: Zyklusende         01:12:08 Ok
    # alles andere wird als fehlerhaft gewertet
    If ($Zyklus -match "Zyklusende\s+(?:(?:([01]?\d|2[0-3]):)?([0-5]?\d):)?([0-5]?\d) Ok") {
        $Fehlerhaft = $False
        $Fehler = ""
    } else {
        $Fehlerhaft = $true
        # möglichst viele Fehlerinformationen ermitteln
        $Fehler = ""
    }

    $DACZyklus = [PSCustomObject]@{
                    PSTypeName="DAC.Zyklus"
                    Seriennummer=$Zyklus[1].Substring(12);
                    Programm=$Zyklus[2].Substring(12);
                    Deckel=$Zyklus[3].Substring(12);
                    Zyklus=[int]$Zyklus[4].Substring(12);
                    Datum=Get-Date "$($Zyklus[5].Substring(12)) $($Zyklus[6].Substring(11))";
                    Phasen="";
                    Fehlerhaft=$Fehlerhaft;
                    Fehler=$Fehler;
                }
    $DACZyklus | Add-Member -Type ScriptProperty -Name Wochentag -Value {(Get-Culture).DateTimeFormat.DayNames[$this.Datum.DayOfWeek.value__]}

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

$z = Analyze-DACLogFile -Path .\DAC.LOG
Test-DACZyklenChronologie $z
