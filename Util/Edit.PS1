# erlaubt das Editieren einer Datei per Notepad und sorgt dafür, dass die Uhrzeit der
# Dateiänderungen von vor dem ändern erhalten bleibt
Function Edit-DACLogFile {
    [CmdletBinding()]
    Param ([string]$path)
  
    $path = Resolve-Path $path
    Write-Verbose $path
  
    If (Test-Path $path) {
        $FileMetaData = Get-ChildItem $path
        $lwt = $FileMetaData.LastWriteTime
        Write-Verbose $lwt
  
        $p = Start-Process Notepad.exe -Argumentlist $path -PassThru
        while (-Not ($p.HasExited)) {
            Start-Sleep -Milliseconds 500
        }
        $FileMetaDataNew = Get-ChildItem $path
        If ($lwt -ne $FileMetaDataNew.LastWriteTime) {
            $FileMetaDataNew.LastWriteTime = $lwt
            If ($lwt -eq ((Get-ChildItem $path).LastWriteTime)) {
                Write-Verbose "Datum erfolgreich zurückgesetzt auf $($lwt)"
            }
        }
    }
}

# liest einen Zyklus aus einer LOG-Datei (.PRO oder .STR), und schreibt dessen Ende-Datum als Zeitstempel der Datei
Function Set-LastWriteTimeFromLogEntry {
    [CmdletBinding()]
    Param ([string]$path)
  
    $path = Resolve-Path $path
    Write-Verbose $path
  
    If (Test-Path $path) {
        $z = Analyze-DacLogFile -Path $path
        If ($z) {
            $FileMetaData = Get-ChildItem $path
            $FileMetaData.LastWriteTime = $z.Ende
            If ($z.Ende -eq ((Get-ChildItem $path).LastWriteTime)) {
                Write-Verbose "Datum erfolgreich gesetzt auf $($z.Ende)"
            }
        }
    }
}
