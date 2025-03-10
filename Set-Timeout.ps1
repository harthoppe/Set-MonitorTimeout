<#
.SYNOPSIS
    Sets the monitor, disk, standby, and hibernate timeouts for AC and/or DC power modes.

.DESCRIPTION
    This script allows you to set the monitor, disk, standby, and hibernate timeouts for AC and/or DC power modes using the powercfg command.
    It logs the actions and any errors to a log file in the TEMP directory.

.PARAMETER AC
    Switch to set the timeouts for AC power mode.

.PARAMETER DC
    Switch to set the timeouts for DC power mode.

.PARAMETER Timeout
    The timeout value in minutes. Must be between 0 and 1440.

.EXAMPLE
    Set-TimeOut -AC -Timeout 10
    Sets the timeouts for AC power mode to 10 minutes.

.EXAMPLE
    Set-TimeOut -DC -Timeout 20
    Sets the timeouts for DC power mode to 20 minutes.

.EXAMPLE
    Set-TimeOut -AC -DC -Timeout 15
    Sets the timeouts for both AC and DC power modes to 15 minutes.

.EXAMPLE
    Set-TimeOut -AC -DC -Timeout 0
    Disables all timeouts for both AC and DC power modes.

.NOTES
    Author: Hart Hoppe
    Date: 2025-03-10
#>

function Set-TimeOut {
    [CmdletBinding()]
    param(
        [switch]$AC,
        [switch]$DC,
        [Parameter()]
        [ValidateRange(0,1440)]
        [int]$Timeout = 0
    )

    if (-not ($AC -or $DC)) {
        $logFile = Join-Path -Path $env:TEMP -ChildPath "Set-TimeOut.log"
        $timeStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        $errorMessage = "You must specify at least one switch: -AC, -DC, or both."
        $entry = "$timeStamp - $errorMessage"
        Add-Content -Path $logFile -Value $entry
        Write-Error $errorMessage
        return
    }

    $logFile = Join-Path -Path $env:TEMP -ChildPath "Set-TimeOut.log"
    $timeStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

    function Write-Log {
        param([string]$Message)
        $entry = "$timeStamp - $Message"
        Add-Content -Path $logFile -Value $entry
    }

    $timeouts = @(
        "monitor-timeout-ac",
        "monitor-timeout-dc",
        "disk-timeout-ac",
        "disk-timeout-dc",
        "standby-timeout-ac",
        "standby-timeout-dc",
        "hibernate-timeout-ac",
        "hibernate-timeout-dc"
    )

    foreach ($timeout in $timeouts) {
        if (($timeout -like "*-ac" -and $AC) -or ($timeout -like "*-dc" -and $DC)) {
            try {
                $command = "powercfg /change $timeout $Timeout"
                Invoke-Expression $command
                Write-Log "Success: Set $timeout to $Timeout minutes."
            }
            catch {
                Write-Log "Error setting $timeout`: $_"
                Write-Error "Error setting $timeout`: $_"
            }
        }
    }
}
