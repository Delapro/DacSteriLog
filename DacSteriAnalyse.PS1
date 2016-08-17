# Script zur Analyse von DAC Sterilisator LOG-Dateien
# die LOG-Datei entspricht nicht den reinen DAC-Daten sondern enthält zusätzliche Informationen,
# welche über ein Powershell Script hinzugefügt werden.
#

# Hier sind die Regeln für Scriptanalyzer zu finden:
# https://github.com/PowerShell/PSScriptAnalyzer/search?utf8=%E2%9C%93&q=unapproved+verb&type=Code
# man bindet folgende Zeile ein und setzt die Regel ein:
# [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "", Scope="Function")]

# Deutsch
$DACUniversal_DE = "DAC Universal"
$Zyklusende_DE = "Zyklusende"
$FehlerID_DE = "FEHL"
$OKID_DE = "Ok"

# Englisch
$DACUniversal_EN = "DAC Universal"
$Zyklusende_EN = "Cycle end"
$FehlerID_EN = "FAIL"
$OKID_EN = "OK"

# Französisch
# TODO:
$DACUniversal_FR = "DAC Universal"
$Zyklusende_FR = "Cycle end"
$FehlerID_FR = "FAIL"
$OKID_FR = "OK"

# Deutsch ist Vorgabe
$DACUniversal = $DACUniversal_DE
$Zyklusende = $Zyklusende_DE
$FehlerID = $FehlerID_DE
$OKID = $OKID_DE

Function Set-LogFileLanguage {
    [CmdletBinding()]
    Param(
        [Switch]$Deutsch,
        [Switch]$English,
        [Switch]$Francais
    )

    If ($Deutsch) {
        $Script:DACUniversal = $DACUniversal_DE
        $Script:Zyklusende = $Zyklusende_DE
        $Script:FehlerID = $FehlerID_DE
        $Script:OKID = $OKID_DE
    }

    If ($English) {
        $Script:DACUniversal = $DACUniversal_EN
        $Script:Zyklusende = $Zyklusende_EN
        $Script:FehlerID = $FehlerID_EN
        $Script:OKID = $OKID_EN
    }

    If ($Francais) {
        $Script:DACUniversal = $DACUniversal_FR
        $Script:Zyklusende = $Zyklusende_FR
        $Script:FehlerID = $FehlerID_FR
        $Script:OKID = $OKID_FR
    }

}

Function Analyze-DACLogFile {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "", Scope="Function")]
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
        [PSTypeName('DAC.Zyklus')]$Zyklen,
        [Switch]$Continue
    )
    
    $Chronologisch = $True

    If ($Zyklen.Count -gt 1) {
        $TestZyklus = $Zyklen[0].Zyklus
        Write-Verbose "Startzyklus: $TestZyklus"
        for ($i = 1; $i -lt $Zyklen.Count; $i++) {
            $NaechsterZyklus = $Zyklen[$i].Zyklus
            If (($TestZyklus +1) -ne $NaechsterZyklus ) {
                Write-Verbose "unerlaubter Zyklensprung von $($NaechsterZyklus - $TestZyklus -1) Zyklen: $TestZyklus auf $NaechsterZyklus"
                $Chronologisch = $False
                If (-Not $Continue) {
                    break
                }
            }
            $TestZyklus = $NaechsterZyklus
        }
    }

    $Chronologisch
}

Function Analyze-DACZyklus {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "", Scope="Function")]
    [CmdletBinding()]
    Param (
        [String[]]$Zyklus
    )

    # Prüfen ob Zyklusende ordentlich da steht
    # Beispiel: Zyklusende         01:12:08 Ok
    # alles andere wird als fehlerhaft gewertet
    If ($Zyklus -match "$Zyklusende\s+(?:(?:([01]?\d|2[0-3]):)?([0-5]?\d):)?([0-5]?\d) $OKID") {
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
                    RawContent=$Zyklus | Out-String
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
                # -1 ist, wichtig, sonst werden nachfolgende Blöcke nicht mehr erkannt!
                # Wir befinden uns ja bereits am Anfang des nächsten Blocks
                $Index = $Index -1
                $end = $Index
            }
        } elseif (($Start -ne -1) -and ($Zeile -match "===----")) {
            Write-Verbose "nächsten Tageseintrag erkannt, Zeile: $Index" 
            $end = $Index
        } else {
            If ($Zeile -match $Zyklusende -and $Start -ne -1) {
                Write-Verbose "Zyklusende erkannt, prüfen ob kein Fehler"
                If (-not ($Zeile -match $FehlerID) ) {
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

Function Write-DACLog {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,valueFromPipeline=$true)]
        [PSTypeName("DAC.Zyklus")]$Zyklen,
        [Parameter(Mandatory = $true,Position = 1)]
        [String]$Path
    )
    foreach ($Zyklus in $Zyklen) {
        #$File = New-Filename -BasePath $Path - 
    }
} 

$z = Analyze-DACLogFile -Path .\DAC.LOG
Test-DACZyklenChronologie $z
