# Set the path to choco.exe
$chocoPath = "$env:SystemDrive\ProgramData\chocolatey\bin"

# Check if Chocolatey is installed
if (!(Test-Path $chocoPath)) {
    
    # Chocolatey is not installed, so install it
    Write-Host "Chocolatey is not installed. Installing now..."
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

    
} else {
    
    # Chocolatey is already installed, so do nothing
    Write-Host "Chocolatey is already installed."
    
}

# Add choco.exe to the user's PATH variable
Write-Host "Adding choco.exe to machine PATH"
$existingPath = [Environment]::GetEnvironmentVariable('Path', 'Machine')

if ($existingPath -notlike "*$chocoPath*") {
    
    $newPath = $existingPath + ';' + $chocoPath
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name 'Path' -Value $newPath

} else {

    Write-Host "Chocolatey alreay in PATH"

}

# Add Chocolatey source for OptConnect
$chocoUser = 'USER'
$chocoPass = Get-Content -Path 'PASS_FILE'
$sourceName = 'REPO_NAME'
$sourceUrl = 'REPO_URL'

if (!(& "$chocoPath\choco.exe" source list | Where-Object {$_ -like $sourceName})) {

    & "$chocoPath\choco.exe" sources add -n "$sourceName" -u "$chocoUser" -p "$chocoPass" -s "$sourceUrl"
    Remove-Item -Path 'PASS_FILE' -Force
    & "$chocoPath\choco.exe" sources enable -n "$sourceName"
    
}

& "$chocoPath\choco.exe" install PACKAGES -y