$volumes = Get-BitLockerVolume

foreach ($vol in $volumes) {
    $recoveryProtectors = $vol.KeyProtector | Where-Object { $_.KeyProtectorType -eq "RecoveryPassword" }

    try {
        if ($recoveryProtectors.Count -gt 0) {
        Write-Host "Drive $($vol.MountPoint) Found $($recoveryProtectors.Count) recovery password protector(s)."

        foreach ($protector in $recoveryProtectors) {
            $password = $protector.RecoveryPassword
            $protectorId = $protector.KeyProtectorId.ToString()

            Write-Host "  Recovery Password : $password"
            Write-Host "  Key Protector ID  : $protectorId"

            BackupToAAD-BitLockerKeyProtector -MountPoint $vol.MountPoint -KeyProtectorId $protectorId
            Write-Host "`nSuccessfully backed up to Azure AD.`n"

            Exit 0
            
        }
    } else {
        Write-Host "Drive $($vol.MountPoint): No recovery password protectors found.`n"
        Exit 1
    }
    } catch {
        Write-Host "An error occurred while backing up the recovery password: $_"
        Exit 1
    }
}
