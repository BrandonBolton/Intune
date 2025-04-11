$tzAutoUpdatePath = "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate"
$tzAutoUpdateValue = 3

$locationConsentPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"
$locationConsentValue = "Allow"

# Function to set registry value
function Set-RegistryValue {
    param (
        [string]$Path,
        [string]$Name,
        [string]$Value
    )
    if ((Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue).$Name -ne $Value) {
        Set-ItemProperty -Path $Path -Name $Name -Value $Value
        Write-Output "Set $Name to $Value at $Path"
    } else {
        Write-Output "$Name is already set to $Value at $Path"
    }
}

# Set registry values for tzautoupdate and location ConsentStore
Set-RegistryValue -Path $tzAutoUpdatePath -Name "Start" -Value $tzAutoUpdateValue
Set-RegistryValue -Path $locationConsentPath -Name "Value" -Value $locationConsentValue
