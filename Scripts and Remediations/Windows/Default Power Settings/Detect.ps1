try {
    $output = powercfg /query

    $standbyIdleDC = $null
    $videoIdleDC = $null

    $standbyIdleAC = $null
    $videoIdleAC = $null

    # Parses the information from the output, pulling DC info first, then AC info
    # These GUIDs are standardized across Windows
    foreach ($line in $output) {
        if ($line -match "Power Setting GUID: 29f6c1db-86da-48c5-9fdb-f2b67b1f44da") {
            $isStandbyIdle = $true
        } elseif ($line -match "Power Setting GUID: 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e") {
            $isVideoIdle = $true
        } elseif ($line -match "Current DC Power Setting Index: (\w+)") {
            if ($isStandbyIdle) {
                $standbyIdleDC = $matches[1]
                $isStandbyIdle = $false
            } elseif ($isVideoIdle) {
                $videoIdleDC = $matches[1]
                $isVideoIdle = $false
            }
        }
    }

    foreach ($line in $output) {
        if ($line -match "Power Setting GUID: 29f6c1db-86da-48c5-9fdb-f2b67b1f44da") {
            $isStandbyIdle = $true
        } elseif ($line -match "Power Setting GUID: 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e") {
            $isVideoIdle = $true
        } elseif ($line -match "Current AC Power Setting Index: (\w+)") {
            if ($isStandbyIdle) {
                $standbyIdleAC = $matches[1]
                $isStandbyIdle = $false
            } elseif ($isVideoIdle) {
                $videoIdleAC = $matches[1]
                $isVideoIdle = $false
            }
        }
    }

    # "STANDBYIDLE Current DC Power Setting Index: $standbyIdleDC"
    # "STANDBYIDLE Current AC Power Setting Index: $standbyIdleAC"
    # "VIDEOIDLE Current DC Power Setting Index: $videoIdleDC"
    # "VIDEOIDLE Current AC Power Setting Index: $videoIdleAC"

    # 0x00000e10 is 60 minutes, 0x000004b0 is 20 minutes
    if ($standbyIdleDC -eq "0x00000e10" -and $videoIdleDC -eq "0x000004b0" -and $standbyIdleAC -eq "0x00000e10" -and $videoIdleAC -eq "0x000004b0") {
        Write-Output "Power settings set correctly"
        exit 0
    } else {
        Write-Output "Power settings not set correctly"
        exit 1
    }
} catch {
    Write-Output "Power settings failed to set"
    exit 1
}
