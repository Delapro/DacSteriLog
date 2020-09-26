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

# entfernt Nullbytes am Anfang der ersten Zeile
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

# holt sich alle Log-Dateien aus dem Unterverzeichnis eines Basisverzeichnis, spielt diese zusammen
# in eine temporäre Datei, liest diese ein, sortiert sie und prüft die Zyklen
Function Test-Zyklen {
    [CmdletBinding()]
    Param(
        [string]$BaseDir,
        [string[]]$LogFileExtension=@("*.PRO", "*.STR")

    )
    
    $z = Get-AllZyklen -BaseDir $BaseDir -LogFileExtension $LogFileExtension
    # TODO
}

<#
.SYNOPSIS
Ermittelt alle Log-Dateien aus einem Basisverzeichnis und gibt diese als DAC.Zyklus-Objekte zurück
#>
Function Get-AllZyklen {
    [CmdletBinding()]
    Param(
        [string]$BaseDir,
        [string[]]$LogFileExtension=@("*.PRO", "*.STR")
    )
    
    $Files = Get-LogFiles -BaseDir $BaseDir -LogFileExtension $LogFileExtension
    Write-Verbose "$($Files.Length)-Dateien ermittelt"
    $Files | ForEach-Object {Analyze-DACZyklus (Get-Content $_.Fullname)}
}

# gibt die Zyklen in einer Gridview aus
Function Show-AllZyklen  {
    [CmdletBinding()]
    Param(
        [string]$BaseDir,
        [string[]]$LogFileExtension=@("*.PRO", "*.STR")

    )
    
    $z = Get-AllZyklen -BaseDir $BaseDir -LogFileExtension $LogFileExtension
    $z | Out-GridView
}

<#
.SYNOPSIS
Ermittelt alle Log-Dateien (Endung *.PRO und *.STR) aus den Unterverzeichnissen eines Basisverzeichnis
#>
Function Get-LogFiles {
    [CmdletBinding()]
    Param(
        [string]$BaseDir,
        [string[]]$LogFileExtension=@("*.PRO", "*.STR")
    )
    $Files = Get-ChildItem $BaseDir -Recurse -Include $LogFileExtension
    $Files
}

<#
.SYNOPSIS
Erstellt eine temporäre Datei mit dem Inhalt aller übergebener Dateien
#>
Function New-LogFile {
    [CmdletBinding()]
    Param(
        [System.IO.FileInfo[]]$File
    )

    for ($i = 0; $i -lt $File.Count; $i++) {
        $Content += Get-Content $File[$i]
    }
# PS5-Only:   $Filename = New-TemporaryFile
    $Filename = [System.IO.Path]::GetTempFileName()
    $Content | Set-Content $Filename 
    $Filename
}
