# Define the groups to be checked
$groups = @("Administrators", "LOCAL SERVICE", "Users", "Authenticated Users")

# Function to verify groups have the "Change the time zone" user right
function Test-TimeZonePermission {
    param (
        [string[]]$Groups
    )
    $result = $true
    foreach ($group in $Groups) {
        $sid = (New-Object System.Security.Principal.NTAccount($group)).Translate([System.Security.Principal.SecurityIdentifier]).Value
        secedit /export /cfg C:\Windows\Temp\secedit.inf
        $content = Get-Content C:\Windows\Temp\secedit.inf
        if ($content -notmatch "SeTimeZonePrivilege = \*$sid") {
            $result = $false
        }
    }
    return $result
}

# Execute the function and set the exit code
if (Test-TimeZonePermission -Groups $groups) {
    Write-Output "All specified groups have the 'Change the time zone' permission."
    exit 0
} else {
    Write-Output "One or more specified groups do NOT have the 'Change the time zone' permission."
    exit 1
}
