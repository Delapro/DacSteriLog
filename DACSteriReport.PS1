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
