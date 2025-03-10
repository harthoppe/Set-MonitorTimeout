<#
.SYNOPSIS
    Sets the monitor timeout for AC and/or DC power modes.

.DESCRIPTION
    This script allows you to set the monitor timeout for AC and/or DC power modes using the powercfg command.
    It logs the actions and any errors to a log file in the TEMP directory.

.PARAMETER AC
    Switch to set the monitor timeout for AC power mode.

.PARAMETER DC
    Switch to set the monitor timeout for DC power mode.

.PARAMETER Timeout
    The timeout value in minutes. Must be between 0 and 1440.

.EXAMPLE
    Set-TimeOut -AC -Timeout 10
    Sets the monitor timeout for AC power mode to 10 minutes.

.EXAMPLE
    Set-TimeOut -DC -Timeout 20
    Sets the monitor timeout for DC power mode to 20 minutes.

.EXAMPLE
    Set-TimeOut -AC -DC -Timeout 15
    Sets the monitor timeout for both AC and DC power modes to 15 minutes.

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

    if ($AC) {
        try {
            $command = "powercfg /change monitor-timeout-ac $Timeout"
            Invoke-Expression $command
            Write-Log "Success: Set monitor-timeout-ac to $Timeout minutes."
        }
        catch {
            Write-Log "Error setting monitor-timeout-ac: $_"
            Write-Error "Error setting monitor-timeout-ac: $_"
        }
    }

    if ($DC) {
        try {
            $command = "powercfg /change monitor-timeout-dc $Timeout"
            Invoke-Expression $command
            Write-Log "Success: Set monitor-timeout-dc to $Timeout minutes."
        }
        catch {
            Write-Log "Error setting monitor-timeout-dc: $_"
            Write-Error "Error setting monitor-timeout-dc: $_"
        }
    }
}
