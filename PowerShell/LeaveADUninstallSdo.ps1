# Check if the computer is joined to a domain and leave it if it is.
if ((Get-WmiObject win32_computersystem).partofdomain -eq $true) {
    $credential = Get-Credential
    $domain = (Get-WmiObject win32_computersystem).domain
    Remove-Computer -UnjoinDomainCredential $credential -Force -Verbose
    Write-Output "
    The computer has been removed from the $domain domain.
    "
}
else {
    Write-Output "
    The computer is not joined to a domain.
    "
}

# Check the registry for software named "SOFTWARE" and uninstall it if present.
$regKey = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object {$_.DisplayName -like "SOFTWARE"}
if ($regKey -gt $null) {
    $uninstallString = ($regKey).UninstallString
    $arguments = $uninstallString.Split(" ")[1..($uninstallString.Split(" ").Count - 1)] -join " "
    Stop-Service "SDO safeguard"
    Start-Process -FilePath $uninstallString.Split(" ")[0] -ArgumentList $arguments -Wait -Passthru #-Force
    Write-Output "
    SOFTWARE has been uninstalled.
    "
}
else {
    Write-Output "
    SOFTWARE is not installed on this computer.
    "
}

# Checks if Internet Explorer is enabled on Windows 10 and disables it
if ((Get-ComputerInfo).OsName -like "*11*") {
    exit 0
} else {
    Write-Host "
    Disabling Internet Explorer...
    "
}

$ieState = Get-WindowsOptionalFeature -FeatureName Internet-Explorer-Optional-amd64 -Online

if ($ieState -eq "Disabled") {
    Write-Host "
    Internet Explorer not enabled, exiting.
    "
    exit 0
} else {
    Disable-WindowsOptionalFeature -FeatureName Internet-Explorer-Optional-amd64 -Online -NoRestart
    Write-Host "
    Internet Explorer disabled.
    "
}