<#
.SYNOPSIS
    Configures monitor timeout settings for AC and/or DC power and optionally disables the screensaver.

.DESCRIPTION
    This script sets the display timeout for specified power conditions.
    By default, the timeout is set to never (0 minutes) unless a specific duration is provided via the -Duration parameter.
    You must specify at least one of the -AC or -DC flags.
    When the -DisableScreensaver switch is used, the script disables the screensaver by modifying the current user's registry setting.

.PARAMETER Duration
    An integer value (in minutes) to specify the monitor timeout.
    Use 0 for no timeout (indefinite). Default is 0.

.PARAMETER AC
    A switch to apply the monitor timeout setting for AC (plugged-in) power.

.PARAMETER DC
    A switch to apply the monitor timeout setting for DC (battery) power.

.PARAMETER DisableScreensaver
    A switch that, when present, disables the screensaver.

.EXAMPLE
    .\Set-MonitorTimeout.ps1 -AC
    Sets monitor timeout to never (indefinite) for AC power only.

.EXAMPLE
    .\Set-MonitorTimeout.ps1 -DC -Duration 20 -DisableScreensaver
    Sets monitor timeout to 20 minutes for DC (battery) power and disables the screensaver.

.EXAMPLE
    .\Set-MonitorTimeout.ps1 -AC -DC -DisableScreensaver
    Sets monitor timeout to never (indefinite) for both AC and DC power and disables the screensaver.

.NOTES
    Running the script with administrative privileges is recommended for full effect.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateRange(0,1440)]
    [int]$Duration = 0,

    [Parameter(Mandatory = $false)]
    [switch]$AC,

    [Parameter(Mandatory = $false)]
    [switch]$DC,

    [Parameter(Mandatory = $false)]
    [switch]$DisableScreensaver
)

# Ensure at least one power option is specified.
if (-not ($AC -or $DC)) {
    Write-Error "You must specify at least one power option: -AC, -DC, or both."
    throw "You must specify at least one power option: -AC, -DC, or both."
}

function Set-MonitorTimeout {
    param (
        [int]$Minutes,
        [bool]$ApplyAC,
        [bool]$ApplyDC
    )
    $timeoutMessage = if ($Minutes -eq 0) { "indefinitely" } else { "$Minutes minute(s)" }
    if ($ApplyAC) {
        Write-Output "Setting monitor timeout to $timeoutMessage on AC power..."
        powercfg /change monitor-timeout-ac $Minutes | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to set monitor timeout for AC power. Exit code: $LASTEXITCODE"
        }
    }
    if ($ApplyDC) {
        Write-Output "Setting monitor timeout to $timeoutMessage on DC (battery) power..."
        powercfg /change monitor-timeout-dc $Minutes | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to set monitor timeout for DC power. Exit code: $LASTEXITCODE"
        }
    }
}

try {
    # Check for administrative privileges
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator")
    if (-not $isAdmin) {
        Write-Warning "Running without administrative privileges. Some settings may not be applied correctly."
    }

    # Define registry path for screensaver settings
    $regPath = "HKCU:\Control Panel\Desktop"

    # Configure monitor timeout for selected power options
    Set-MonitorTimeout -Minutes $Duration -ApplyAC $AC -ApplyDC $DC

    # Optionally disable the screensaver inline
    if ($DisableScreensaver) {
        Write-Output "Disabling screensaver..."
        try {
            Set-ItemProperty -Path $regPath -Name ScreenSaveActive -Value "0"
            Write-Output "Screensaver has been disabled."
        }
        catch {
            Write-Error "Failed to disable screensaver: $_"
        }
    }

    Write-Output "Configuration complete."
}
catch {
    Write-Error "An error occurred: $_"
}
