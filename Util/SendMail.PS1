Function Send-EMailNet {
    [CmdletBinding()]
    Param(
        [String]$Subject,
        [String]$HtmlMessage
    )

    $to = "toyouruser@fromyourserver.reg"
    $smtp = "smtp.fromyourserver.reg"
    $port = 587
    $password = "yourpassword"
    $from = "youraddress@fromyourserver.reg"

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

    $html = [System.Net.Mail.AlternateView]::CreateAlternateViewFromString($HtmlMessage, $null, "text/html")
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
