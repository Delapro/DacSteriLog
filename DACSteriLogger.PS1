Function New-WatchDog {
    [CmdletBinding()]
    Param(
        [long]$TimeOutMilliseconds,
        [long]$TimeOutSeconds,
        [long]$TimeOutMinutes
    )

    If (-Not $TimeOutMinutes) {
        $TimeOutMilliseconds = $TimeOutMinutes * 60 * 1000
    }

    If (-Not $TimeOutSeconds) {
        $TimeOutMilliseconds = $TimeOutSeconds * 1000
    }

    If (-Not $TimeOutMilliseconds) {
        $TimeOutMilliseconds = 0
    }

    $w = [PSCustomObject]@{PSTypeName="DAC.WatchDog";
                        Interval=$TimeOutMilliseconds;
                    }

    $w | Add-Member -MemberType ScriptProperty -Name WatchDog -Value { {"Ja"}}

    $w
}

Function Get-WatchDog {
    [CmdletBinding()]
    Param(
        [PSTypeName("DAC.WatchDog")]
        $WatchDog
    )
    $WatchDog
}

Function Test-WatchDog {
    [CmdletBinding()]
    Param(
        [PSTypeName("DAC.WatchDog")]
        $WatchDog
    )
    $WatchDog
}
