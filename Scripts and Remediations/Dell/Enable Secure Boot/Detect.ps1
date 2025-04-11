$RegistryPath = "HKLM:\SOFTWARE\COMPANYNAME\Intune\Dell"
$RegistryKey = "SecureBootEnabled"

try {
    if (Test-Path $RegistryPath) {
        $RegValue = Get-ItemProperty -Path $RegistryPath -ErrorAction SilentlyContinue
        if ($RegValue -and $RegValue.PSObject.Properties.Name -contains $RegistryKey) {
            Write-Host "Registry key found."
            Exit 0
        } else {
            Write-Host "Registry key not found."
            Exit 1
        }
    } else {
        Write-Host "Registry path not found."
        Exit 1
    }
} catch {
    Write-Host "Error accessing registry: $_"
    Exit 1
}