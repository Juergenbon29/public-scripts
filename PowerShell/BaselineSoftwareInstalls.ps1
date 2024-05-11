###     Installs all software for Windows systems using chocolatey      ###

$packages = @(
    "PACKAGE_LIST"
)
$testChoco = choco -v

if (-not ($testChoco)) {
    Write-Output "Chocolatey not installed, installing now..."
    Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
} else {
    Write-Output "Chocolatey version $testChoco is already installed"
}

foreach($package in $packages){
    if ((choco list $package -lo).Length -lt 3) {
        choco install $package -y
    } else {
        Write-Host "Package installed, moving to the next..."
    }
}