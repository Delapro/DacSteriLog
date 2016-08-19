# prüft ob Nullbytes in der ersten Zeile am Anfang vorkommen
Function Test-NullBytesInLogFile {
    [CmdletBinding()]
    Param(
        [System.IO.FileInfo[]]$File
    )

    for ($i = 0; $i -lt $File.Count; $i++) {
        $Content = Get-Content -Path $File[$i].FullName 
        If ($Content[0].StartsWith([char]0)) {
            $true
        } else {
            $false
        }        
    }
}

# enrfernt Nullbytes am Anfang der ersten Zeile
Function Remove-NullBytesInLogFile {
    [CmdletBinding()]
    Param(
        [System.IO.FileInfo[]]$File
    )

    for ($i = 0; $i -lt $File.Count; $i++) {
        Write-Verbose "Bearbeite $($File[$i].Fullname)"
        $Datum = $File[$i].LastWriteTime
        $Content = Get-Content -Path $File[$i].FullName
        $Content[0] = $Content[0].TrimStart([char]0) 
        $Content | Set-Content -Path $File[$i].FullName -Force
        $File[$i].LastWriteTime = $datum 
    }
}

