$volumes = Get-BitLockerVolume

if ($volumes.Count -eq 0) {
    Write-Host "No BitLocker volumes found."
    exit 0
}
else {
    Write-Host "BitLocker volumes found."
    exit 1
}