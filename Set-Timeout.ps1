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

.PARAMETER Duration
    The timeout value in minutes. Must be between 0 and 1440.

.EXAMPLE
    Set-TimeOut -AC -Duration 10
    Sets the timeouts for AC power mode to 10 minutes.

.EXAMPLE
    Set-TimeOut -DC -Duration 20
    Sets the timeouts for DC power mode to 20 minutes.

.EXAMPLE
    Set-TimeOut -AC -DC -Duration 15
    Sets the timeouts for both AC and DC power modes to 15 minutes.

.EXAMPLE
    Set-TimeOut -AC -DC -Duration 0
    Disables all timeouts for both AC and DC power modes.

.NOTES
    Author: Hart Hoppe
    Date: 2025-03-10
#>

$logFile = Join-Path -Path $env:TEMP -ChildPath "Set-TimeOut.log"

function Write-Log {
    param([string]$Message)
    $timeStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $entry = "$timeStamp - $Message"
    Add-Content -Path $logFile -Value $entry
    Write-Output $Message
}

function Handle-MissingSwitchError {
    $errorMessage = "You must specify at least one switch: -AC, -DC, or both."
    Write-Log $errorMessage
}

function Set-TimeOut {
    [CmdletBinding()]
    param(
        [switch]$AC,
        [switch]$DC,
        [Parameter()]
        [ValidateRange(0,1440)]
        [int]$Duration = 0  # Default value is 0, which disables all timeouts
    )

    if (-not ($AC -or $DC)) {
        Handle-MissingSwitchError
        return
    }

    $acTimeouts = @(
        "monitor-timeout-ac",
        "disk-timeout-ac",
        "standby-timeout-ac",
        "hibernate-timeout-ac"
    )

    $dcTimeouts = @(
        "monitor-timeout-dc",
        "disk-timeout-dc",
        "standby-timeout-dc",
        "hibernate-timeout-dc"
    )

    if ($AC) {
        foreach ($timeout in $acTimeouts) {
            try {
                $command = "powercfg /change $timeout $Duration"
                Invoke-Expression $command
                Write-Log "Success: Set $timeout to $Duration minutes."
            }
            catch {
                Write-Log "Error setting $timeout to $Duration minutes: $_"
            }
        }
    }

    if ($DC) {
        foreach ($timeout in $dcTimeouts) {
            try {
                $command = "powercfg /change $timeout $Duration"
                Invoke-Expression $command
                Write-Log "Success: Set $timeout to $Duration minutes."
            }
            catch {
                Write-Log "Error setting $timeout to $Duration minutes: $_"
            }
        }
    }
}

# # UNCOMMENT TO USE AS A MODULE
# # Export the Set-TimeOut function
# Export-ModuleMember -Function Set-TimeOut

# Call the Set-TimeOut function with the specified parameters
Set-TimeOut -AC -DC -Duration 0