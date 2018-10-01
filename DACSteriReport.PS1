# Script um einfache Reports für DAC Sterilisator erstellen zu können
#

# Datum des aktuellen Wochenanfang oder des Wochenendes oder eines bestimmten Tages in der Woche zu erhalten
# werden kein Parameter oder nur -Date angegeben, wird die Wochennummer zurückgegeben
# Beispiele:
# Get-Week
# Get-Week -BeginOfWeek
# Get-Week -EndOfWeek
# Get-Week -Friday
# Get-Week -Saturday
# Get-Week -Date 17.1.2017 -BeginOfWeek
Function Get-Week {
    [CmdletBinding()]
    Param(
        [DateTime]$Date=(Get-Date),
        [Switch]$BeginOfWeek,
        [Switch]$EndOfWeek,
        [Switch]$Friday,
        [Switch]$Saturday
    )

    $dfi=[System.Globalization.DateTimeFormatInfo]::CurrentInfo
    $dayOfWeek = $Date.DayOfWeek
    If ($dayOfWeek -eq 0) {
        # damit die Berechnungen unten auch Sonntags klappen
        $dayOfWeek = 7
    }

    If ($BeginOfWeek) {
        $date.AddDays(($dayOfWeek - $dfi.FirstDayOfWeek) *-1).Date
    } elseif ($EndOfWeek) {
        $date.AddDays(($dayOfWeek - $dfi.FirstDayOfWeek) *-1).Date.AddDays(7).Date.AddSeconds(-1)
    } elseif ($Friday) {
        $date.AddDays(($dayOfWeek - [System.DayOfWeek]::Friday) *-1).Date.AddDays(1).Date.AddSeconds(-1)
    } elseif ($Saturday) {
        $date.AddDays(($dayOfWeek - [System.DayOfWeek]::Saturday) *-1).Date.AddDays(1).Date.AddSeconds(-1)
    } else {
        $cal=$dfi.Calendar
        $cal.GetWeekOfYear($Date.Date, $dfi.CalendarWeekRule, $dfi.FirstDayOfWeek)
    }

}

# ermittelt zu einem Datum den ersten Zeitpunkt des Tages, wenn kein Datum übergeben wird, vom aktuellen Tag
Function Get-StartOfDay {
    [CmdletBinding()]
    Param(
        [DateTime]$Date=(Get-Date),
        [Switch]$Yesterday
    )

    If ($Yesterday) {
        $Date = $Date.AddDays(-1)
    }

    $Date.Date
}

# ermittelt zu einem Datum den letzten Zeitpunkt des Tages, wenn kein Datum übergeben wird, vom aktuellen Tag
Function Get-EndOfDay {
    [CmdletBinding()]
    Param(
        [DateTime]$Date=(Get-Date),
        [Switch]$Yesterday
    )

    If ($Yesterday) {
        $Date = $Date.AddDays(-1)
    }

    $Date.Date.AddDays(1).AddMilliseconds(-1)
}

# ermittelt Daten die zwischen zwei Wochentagen mit bestimmter Uhrzeit liegen
Function Test-BetweenWeekdays {
    [CmdletBinding()]
    Param(
        [Parameter(ParameterSetName="DatumString")]
        [Parameter(ParameterSetName="DatumDate")]
        [DateTime]$Datum,
        #[Parameter(ParameterSetName="DatumString")][System.DayOfWeek]$VonWochentag,
        [Parameter(ParameterSetName="DatumString")][ValidateSet('Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag')]
        [String]$VonWochentag,
        [Parameter(ParameterSetName="DatumString")][ValidatePattern("^(([01][0-9])|2[0-3]):[0-5][0-9]")]
        [String]$VonUhrzeit,
        #Parameter(ParameterSetName="DatumString")][System.DayOfWeek]
        [Parameter(ParameterSetName="DatumString")][ValidateSet('Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag')]
        [String]$BisWochentag,
        [Parameter(ParameterSetName="DatumString")][ValidatePattern("^(([01][0-9])|2[0-3]):[0-5][0-9]")]
        [String]$BisUhrzeit,
        [Parameter(ParameterSetName="DatumDate")][DateTime]$Wochenanfang,
        [Parameter(ParameterSetName="DatumDate")][DateTime]$Wochenende
    )

    If ($PSCmdlet.ParameterSetName -eq "DatumDate") {
        $VonWochentag = [System.Globalization.CultureInfo]::CurrentUICulture.DateTimeFormat.GetDayName($Wochenanfang.DayOfWeek)
        $VonUhrzeit = $Wochenanfang.TimeOfDay.ToString()
        $BisWochentag = [System.Globalization.CultureInfo]::CurrentUICulture.DateTimeFormat.GetDayName($Wochenende.DayOfWeek)
        $BisUhrzeit = $Wochenende.TimeOfDay.ToString()
    }

    $DatumWochentag = [System.Globalization.CultureInfo]::CurrentUICulture.DateTimeFormat.GetDayName($Datum.DayOfWeek)
    $DatumUhrzeit = $Datum.TimeOfDay.ToString()

    $von = (Get-DayOfWeek $VonWochentag).value__ * [TimeSpan]::TicksPerDay + ([TimeSpan]$VonUhrzeit).Ticks
    $bis = (Get-DayOfWeek $BisWochentag).value__ * [TimeSpan]::TicksPerDay + ([TimeSpan]$BisUhrzeit).Ticks
    $now = (Get-DayOfWeek $DatumWochentag).value__ * [TimeSpan]::TicksPerDay + ([TimeSpan]$DatumUhrzeit).Ticks

    Write-Verbose "$von <= $now <= $bis"

    $von -le $now -and $now -le $bis
}

# Konvertiert einen deutschen Wochentag in die englische Invariant-Variante
Function Convert-WochentagToInvariant {
    [CmdletBinding()]
    Param(
        [ValidateSet('Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag')]
        $Wochentag
    )

    switch ($Wochentag) {
        'Montag'        {'Monday'}
        'Dienstag'      {'Tuesday'}
        'Mittwoch'      {'Wednesday'}
        'Donnerstag'    {'Thursday'}
        'Freitag'       {'Friday'}
        'Samstag'       {'Saturday'}
        'Sonntag'       {'Sunday'}
    }

}

# Ermittelt zum übergebenen deutschen Wochentag die zugehörige System-Enum-Variante
Function Get-DayOfWeek{
    [CmdletBinding()]
    Param(
        [ValidateSet('Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag')]
        $Wochentag
    )

    [System.DayOfWeek][System.Enum]::Parse([System.DayOfWeek], (Convert-WochentagToInvariant $Wochentag), $true)
}
