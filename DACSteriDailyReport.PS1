# Start-Transcript C:\Script.log

# Wichtig, bei nachzuladenden Scripten muss immer der komplette Pfad angegeben werden, damit es im System-Kontext
# keine Probleme gibt!
If ($MyInvocation.InocationName -eq "") {
    $ScriptDir = "."
} else {
    $ScriptDir = "$((Get-Item $MyInvocation.Invocationname).DirectoryName)"
}

. $ScriptDir\util\SendMail.PS1

Function Send-DACEMailReport {
    [CmdletBinding()]
    Param(
        [String]$Meldung,
        [bool]$Alarm,
        [String]$Fehler
    )

    if ($alarm) {
        $subject = "Neues vom DAC mit Problemen $([char]::ConvertFromUtf32(0x01F44E))"
    } else {
        $subject = "Neues vom DAC $([char]::ConvertFromUtf32(0x01F44D))"
    }

    if ($alarm) {
        $htmlInhalt = "<font face='Arial'><h2>Nachricht vom DAC am $($env:COMPUTERNAME):<span style='color:red'> $meldung</span></h2><span><p><p><p><br>"
  
        # vor der Ausgabe ein einzelnes Element in Array wandeln
        if ($fehler -isnot [array]) {
            $fehler = [array]($fehler)
        }

        foreach ($f in $fehler) {
            # $de = New-Object system.globalization.cultureinfo("de-DE")
            # $timeCreated = get-date $f.TimeCreated -format ($de.DateTimeFormat.UniversalSortableDateTimePattern)
            # $htmlInhalt += "$($timeCreated)   ID:$($f.ID)<BR><P>$($f.Message)</P><BR><BR>"
            # TODO: Fehler hinzufügen
        }
    } else {
        $htmlInhalt = "<font face='Arial'><h2>Nachricht vom DAC am $($env:COMPUTERNAME): $meldung</h2><span><p>"
    }

    Send-EMailNet -Subject $subject -HtmlMessage $htmlInhalt
}

Send-DACEMailReport -Meldung "Alles gut" -Alarm $false -Fehler $null
