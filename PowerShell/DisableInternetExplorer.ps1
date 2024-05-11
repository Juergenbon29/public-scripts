# Checks if Internet Explorer is enabled and disables it
$ieState = Get-WindowsOptionalFeature -FeatureName Internet-Explorer-Optional-amd64 -Online

if ($ieState -eq "Disabled") {
    Write-Host "
    Internet Explorer not enabled, exiting
    "
    exit 0
} else {
    Disable-WindowsOptionalFeature -FeatureName Internet-Explorer-Optional-amd64 -Online -NoRestart
    Write-Host "
    Internet Explorer disabled
    "
}