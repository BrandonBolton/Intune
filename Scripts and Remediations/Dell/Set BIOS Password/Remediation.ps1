$RegistryPath = "HKLM:\SOFTWARE\COMPANYNAME\Intune\Dell"
$RegistryKey = "BIOSPassword"

$NewPassword = "SecurePassword123"
$LogFilePath = "C:\Temp\Intune\Logs\DellWorkstation-SetBIOSPassword.log"

# Make sure the log directory exists
if (-not (Test-Path -Path (Split-Path $LogFilePath))) {
    New-Item -ItemType Directory -Path (Split-Path $LogFilePath) -Force | Out-Null
}

# Helper function to log messages to a file
function Write-Log {
    param (
        [string]$Message
    )
    $Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $LogMessage = "$Timestamp - $Message"
    Add-Content -Path $LogFilePath -Value $LogMessage
}

# Forces the install of DellBIOSProvider, and imports the module. All are required for no user prompts
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Install-Module -Name DellBIOSProvider -Force -AllowClobber -SkipPublisherCheck
Import-Module DellBIOSProvider

# Function to set a registry key
function Set-RegistryKey {
    param (
        [string]$Path,
        [string]$KeyName,
        [string]$Value
    )
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    Set-ItemProperty -Path $Path -Name $KeyName -Value $Value
}

# Check if the registry key exists and is set
$RegistryValue = (Get-ItemProperty -Path $RegistryPath -ErrorAction SilentlyContinue).$RegistryKey

if ($null -eq $RegistryValue) {
    # If the registry value doesn't exist, set the BIOS password
    Write-Log "Registry binary setting not found. Setting BIOS password..."
    Set-Item -Path DellSmbios:\Security\AdminPassword $NewPassword

    # Create the registry key and set a value
    Set-RegistryKey -Path $RegistryPath -KeyName $RegistryKey -Value 0
    Write-Log "BIOS password set, and registry key created with an initial value of 0."
} else {
    Write-Log "Registry setting found, exiting if statement."
    continue
}

Write-Log "Script execution completed."