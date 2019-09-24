# Script zur Manipulation von DAC Objekten welche mit DacSteriAnalyse.PS1 eingelesen wurden

# erlaubt das Klonen von DACZyklus-Objekten, dabei kann das Datum, der Zyklus sowie die
# DAC-Gerätenummer neu gesetzt werden
Function Clone-DACZyklus {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "", Scope="Function")]
    [CmdletBinding()]
    Param (
        # [PSTypeName('DAC.Zyklus')]
        $Zyklus,
        [DateTime]$NewDate,
        [System.Int32]$NewZyklus,
        [System.String]$NewSerialNumber
    )

    $OldDateBeginn = Get-Date $Zyklus.Beginn
    $OldDateEnde = Get-Date $Zyklus.Ende
    If ($null -eq $NewDate) {
        $NewDateBeginn = $Zyklus.Beginn
        $NewDateEnde = $Zyklus.Ende
    } else {
        $NewDateBeginn = (Get-Date $NewDate.Date).AddTicks($Zyklus.Beginn.TimeOfDay.Ticks)
        $NewDateEnde = (Get-Date $NewDate.Date).AddTicks($Zyklus.Ende.TimeOfDay.Ticks)
        $DiffDays = ((Get-Date $Zyklus.Ende.Date) - (Get-Date $Zyklus.Beginn.Date)).days
        If ($DiffDays -ne 0) {
            $NewDateEnde.AddDays($DiffDays)
        }
    }

    $OldZyklus = $Zyklus.Zyklus
    If ($null -eq $NewZyklus) {
        $NewZyklus = $Zyklus.Zyklus
    }
    
    $OldSerialNumber = $Zyklus.Seriennummer
    If ($null -eq $NewSerialNumber) {
        $NewSerialNumber = $Zyklus.Seriennummer
    }

    $DACZyklus = [PSCustomObject]@{
                    PSTypeName="DAC.Zyklus"
                    Seriennummer=$NewSerialNumber;
                    Programm=$Zyklus.Programm;
                    Deckel=$Zyklus.Deckel;
                    Zyklus=$NewZyklus;
                    Beginn=$NewDateBeginn;
                    Ende=$NewDateEnde;
                    Dauer=$Zyklus.Dauer;
                    Phasen=$Zyklus.Phasen;
                    Fehlerhaft=$Zyklus.Fehlerhaft;
                    Fehler=$Zyklus.Fehler;
                    MehrereFehler=$Zyklus.MehrereFehler;
                    RawContent=$Zyklus.RawContent. `
                            Replace((Get-Date $OldDateBeginn -Format 'dd-MM-yyyy'), (Get-Date $NewDateBeginn -Format 'dd-MM-yyyy')). `
                            Replace("Zyklus:     $OldZyklus", "Zyklus:     $NewZyklus"). `
                            Replace($OldSerialNumber, $NewSerialNumber)
                }
    $DACZyklus | Add-Member -Type ScriptProperty -Name Wochentag -Value {(Get-Culture).DateTimeFormat.DayNames[$this.Beginn.DayOfWeek.value__]}

    $DACZyklus
}

Function Clone-DACZyklen {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "", Scope="Function")]
    [CmdletBinding()]
    Param (
        # [PSTypeName('DAC.Zyklus')]
        $Zyklen,
        [DateTime]$NewDate,
        [System.Int32]$NewZyklus,
        [System.String]$NewSerialNumber
    )

    If ($null -ne $NewZyklus) {
        $StartZyklus = $NewZyklus
    }

    $Clone = @()
    foreach ($Zyklus in $Zyklen) {
        If ($null -eq $StartZyklus) {
            $Clone += Clone-DACZyklus -Zyklus $Zyklus -NewDate $NewDate -NewSerialNumber $NewSerialNumber
        } else {
            $Clone += Clone-DACZyklus -Zyklus $Zyklus -NewDate $NewDate -NewZyklus $NewZyklus -NewSerialNumber $NewSerialNumber
            $NewZyklus++
        }
    }

    $Clone
}
