# Script zur Manipulation von DAC Objekten welche mit DacSteriAnalyse.PS1 eingelesen wurden

# erlaubt das Klonen von DACZyklus-Objekten, dabei kann das Datum, der Zyklus sowie die
# DAC-Gerätenummer neu gesetzt werden
Function Clone-DACZyklus {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "", Scope="Function")]
    [CmdletBinding()]
    Param (
        [PSTypeName('DAC.Zyklus')]$Zyklus,
        [DateTime]$NewDate,
        [System.Int32]$NewZyklus,
        [System.String]$NewSerialNumber
    )

    If ($null -eq $NewDate) {
        $NewDateBeginn = $Zyklus.Beginn
        $NewDateEnde = $Zyklus.Ende
    } else {
        $OldDateBeginn = Get-Date $Zyklus.Beginn
        $OldDateEnde = Get-Date $Zyklus.Ende
        $NewDateBeginn = (Get-Date $Zyklus.Beginn.Date).AddTicks($Zyklus.Beginn.TimeOfDay.Ticks)
        $NewDateEnde = (Get-Date $Zyklus.Ende.Date).AddTicks($Zyklus.Ende.TimeOfDay.Ticks)
        $DiffDays = (Get-Date $Zyklus.Ende.Date - Get-Date $Zyklus.Beginn.Date).days
        If ($DiffDays -ne 0) {
            $NewDateEnde.AddDays($DiffDays)
        }
    }

    If ($null -eq $NewZyklus) {
        $NewZyklus = $Zyklus.Zyklus
    }
    
    If ($null -eq $NewSerialNumber) {
        $NewSerialNumber = $Zyklus.Seriennummer
    }

    $DACZyklus = [PSCustomObject]@{
                    PSTypeName="DAC.Zyklus"
                    Seriennummer=$NewSerialNumber;
                    Programm=$Zyklus.Programm;
                    Deckel=$Zyklus.Deckel;
                    Zyklus=$NewZyklus
                    Beginn=$NewDateBeginn
                    Ende=$NewDateEnde
                    Dauer=$Dauer
                    Phasen="";
                    Fehlerhaft=$Fehlerhaft;
                    Fehler=$Fehler;
                    MehrereFehler=$MehrereFehler;
                    RawContent=$Zyklus.RawContent.Replace((Get-Date $OldDatumBeginn -Format 'dd-MM-yyyy'), (Get-Date $NewDatumBeginn -Format 'dd-MM-yyyy'))
                }
    $DACZyklus | Add-Member -Type ScriptProperty -Name Wochentag -Value {(Get-Culture).DateTimeFormat.DayNames[$this.Beginn.DayOfWeek.value__]}

    $DACZyklus
}
