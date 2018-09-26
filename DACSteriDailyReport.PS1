Function Send-EMailNet {
    [CmdletBinding()]
    Param(
        [String]$Meldung,
        [bool]$Alarm,
        [String]$Fehler
    )

    $to = "toyouruser@fromyourserver.reg"
    $smtp = "smtp.fromyourserver.reg"
    $port = 587
    $password = "yourpassword"
    $from = "youraddress@fromyourserver.reg"
    if ($alarm) {
	    $subject = "Neues vom DAC mit Problemen $([char]::ConvertFromUtf32(0x01F44E))"
    } else {
	    $subject = "Neues vom DAC $([char]::ConvertFromUtf32(0x01F44D))"
    }

    $mail = New-Object System.Net.Mail.MailMessage
    $mail.From = $from
    $to = $to.Trim().Replace(";",",")
    try
    {
        $mail.to.Add($to)
    }
    catch
    {
        Write-Host "Empfänger $to konnte nicht gesetzt werden"
    }
    $mail.Subject = $subject

    add-type -assemblyname System.web
    #$kunID = [System.Web.HttpUtility]::UrlEncode($kunID)
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

    $html = [System.Net.Mail.AlternateView]::CreateAlternateViewFromString($htmlInhalt, $null, "text/html")
    # $imageToSend = New-Object System.Net.Mail.LinkedResource($pngLogo)
    # $imageToSend.ContentId = "logo"
    # $html.LinkedResources.Add($imageToSend)
    $mail.AlternateViews.Add($html)

    $mail.IsBodyHtml = 1

    # $attachment = New-Object System.Net.Mail.Attachment(

    $smtpClient = New-Object System.Net.Mail.SmtpClient
    $smtpClient.Host = $smtp
    $smtpClient.Port = $port
    # die Credentials Sachen sind wichtig, sonst gehen die E-Mails nicht an externe Empfänger!
    $smtpClient.UseDefaultCredentials = $true
    $credentials = New-Object System.Net.NetworkCredential -ArgumentList ($from, $password);
    $smtpClient.Credentials = $credentials
    $smtpClient.EnableSsl = $true
    $smtpClient.Send($mail)
    Write-Verbose "E-Mail an $to gesendet"

}
