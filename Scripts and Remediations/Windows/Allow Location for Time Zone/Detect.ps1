$tzAutoUpdatePath = "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate"
$tzAutoUpdateKey = "Start"
$tzAutoUpdateValue = 3

$locationConsentPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"
$locationConsentKey = "Value"
$locationConsentValue = "Allow"

try {
    # Check tzautoupdate Start value
    if (Test-Path $tzAutoUpdatePath) {
        $tzAutoUpdateRegValue = Get-ItemProperty -Path $tzAutoUpdatePath -ErrorAction SilentlyContinue
        if ($tzAutoUpdateRegValue -and $tzAutoUpdateRegValue.PSObject.Properties.Name -contains $tzAutoUpdateKey -and $tzAutoUpdateRegValue.$tzAutoUpdateKey -eq $tzAutoUpdateValue) {
            Write-Host "tzautoupdate Start value is set correctly."
        } else {
            Write-Host "tzautoupdate Start value is not set correctly."
            Exit 1
        }
    } else {
        Write-Host "tzautoupdate path not found."
        Exit 1
    }

    # Check location ConsentStore value
    if (Test-Path $locationConsentPath) {
        $locationConsentRegValue = Get-ItemProperty -Path $locationConsentPath -ErrorAction SilentlyContinue
        if ($locationConsentRegValue -and $locationConsentRegValue.PSObject.Properties.Name -contains $locationConsentKey -and $locationConsentRegValue.$locationConsentKey -eq $locationConsentValue) {
            Write-Host "location ConsentStore value is set correctly."
        } else {
            Write-Host "location ConsentStore value is not set correctly."
            Exit 1
        }
    } else {
        Write-Host "location ConsentStore path not found."
        Exit 1
    }

    Write-Host "All registry keys are set correctly."
    Exit 0
} catch {
    Write-Host "Error accessing registry: $_"
    Exit 1
}