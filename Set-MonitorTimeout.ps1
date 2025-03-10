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
        Write-Error "You must specify at least one switch: -AC, -DC, or both."
        return
    }

    $logFile = Join-Path -Path $env:TEMP -ChildPath "Set-TimeOut.log"
    $timeStamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

    function Log-Message {
        param([string]$Message)
        $entry = "$timeStamp - $Message"
        Add-Content -Path $logFile -Value $entry
    }

    if ($AC) {
        try {
            $command = "powercfg /change monitor-timeout-ac $Timeout"
            Invoke-Expression $command
            Log-Message "Success: Set monitor-timeout-ac to $Timeout minutes."
        }
        catch {
            Log-Message "Error setting monitor-timeout-ac: $_"
            Write-Error "Error setting monitor-timeout-ac: $_"
        }
    }

    if ($DC) {
        try {
            $command = "powercfg /change monitor-timeout-dc $Timeout"
            Invoke-Expression $command
            Log-Message "Success: Set monitor-timeout-dc to $Timeout minutes."
        }
        catch {
            Log-Message "Error setting monitor-timeout-dc: $_"
            Write-Error "Error setting monitor-timeout-dc: $_"
        }
    }
}
