try {
    Powercfg /Change monitor-timeout-ac 20
    Powercfg /Change monitor-timeout-dc 20
    Powercfg /Change standby-timeout-ac 60
    Powercfg /Change standby-timeout-dc 60
    Write-Output "Power settings set successfully"
} catch {
    Write-Output "Power settings failed to set"
}
