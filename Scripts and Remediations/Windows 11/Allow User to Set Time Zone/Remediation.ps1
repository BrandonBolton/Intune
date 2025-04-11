# Define the groups to be added
$groups = @("Administrators", "LOCAL SERVICE", "Users", "Authenticated Users")

# Function to add groups to the "Change the time zone" user right
function Add-TimeZonePermission {
    param (
        [string[]]$Groups
    )
    foreach ($group in $Groups) {
        $sid = (New-Object System.Security.Principal.NTAccount($group)).Translate([System.Security.Principal.SecurityIdentifier]).Value
        $seceditContent = Get-Content "C:\Windows\Temp\secedit.inf"
        if ($seceditContent -notmatch "SeTimeZonePrivilege =") {
            Add-Content "C:\Windows\Temp\secedit.inf" "SeTimeZonePrivilege = *$sid"
        } else {
            (Get-Content "C:\Windows\Temp\secedit.inf") -replace "SeTimeZonePrivilege = ", "SeTimeZonePrivilege = *$sid" | Set-Content "C:\Windows\Temp\secedit.inf"
        }
    }
    secedit /configure /db C:\Windows\Temp\secedit.sdb /cfg C:\Windows\Temp\secedit.inf /areas USER_RIGHTS
}

# Execute the function
Add-TimeZonePermission -Groups $groups
Write-Output "The 'Change the time zone' permission has been set for the specified groups."