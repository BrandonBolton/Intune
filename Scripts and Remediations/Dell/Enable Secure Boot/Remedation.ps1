$RegistryPath = "HKLM:\SOFTWARE\COMPANYNAME\Intune\Dell"
$RegistryKey = "SecureBootEnabled"
$BiosPasswordRegKey = "BIOSPassword"
$BIOSPassword = "SecurePassword123"

$LogFilePath = "C:\Temp\Intune\Logs\DellWorkstation-SecureBootEnabled.log"

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

# Gets current Secure Boot and BIOS password status
$SecureBootValue = Get-Item -Path DellSmbios:\SecureBoot\SecureBoot | Select-Object -ExpandProperty CurrentValue
$BiosPasswordRegKey = (Get-ItemProperty -Path $RegistryPath -ErrorAction SilentlyContinue).$BiosPasswordRegKey

if ($null -eq $BiosPasswordRegKey) {
    # If the registry value doesn't exist, set the BIOS password
    Write-Log "BIOS password not set. Attempting to set Secure Boot without it."

    if ($SecureBootValue -eq "enabled") {
        # If the registry value exists, set registry to 2
        Write-Log "Registry binary setting found. Secure Boot is already enabled. Set registry to 2."
        Set-RegistryKey -Path $RegistryPath -KeyName $RegistryKey -Value 2
    
    } else {
        # If the registry value doesn't exist, enable Secure Boot
        Write-Log "Registry binary setting not found. Enabling Secure Boot..."
        Set-Item DellSmbios:\SecureBoot\SecureBoot enabled
    
        # Create the registry key and set a value
        Set-RegistryKey -Path $RegistryPath -KeyName $RegistryKey -Value 1
        Write-Log "Secure Boot enabled, and registry key created with an initial value of 1."
    }
}
else {
    if ($SecureBootValue -eq "enabled") {
        # If the registry value exists, set registry to 2
        Write-Log "Registry binary setting found. Secure Boot is already enabled. Set registry to 2."
        Set-RegistryKey -Path $RegistryPath -KeyName $RegistryKey -Value 2
    
    } else {
        # If the registry value doesn't exist, enable Secure Boot
        Write-Log "Registry binary setting not found. Enabling Secure Boot..."
        Set-Item DellSmbios:\SecureBoot\SecureBoot enabled -Password $BIOSPassword
    
        # Create the registry key and set a value
        Set-RegistryKey -Path $RegistryPath -KeyName $RegistryKey -Value 1
        Write-Log "Secure Boot enabled, and registry key created with an initial value of 1."
    }
}


Write-Log "Script execution completed."