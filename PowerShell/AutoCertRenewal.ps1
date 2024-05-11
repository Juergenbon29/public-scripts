# Automatically imports new wildcard cert.
#
# .pfx file will have to be created and uploaded to the necessary location with renewal each year
#
# Command to generate .pfx: openssl pkcs12 -export -out DOMAIN-YEAR.pfx -inkey DOMAIN.key -in DOMAIN.crt
#
# YEAR represents the year for the cert - It must be renamed to the format above to work with this script
#
# Once you run the openssl command it will prompt for a password - Make sure to save the password in the vault

$url = "KEY_LOCATION"
$token = "TOKEN"
$checkCert = Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.NotAfter -le (Get-Date).AddDays(30) }

if ($checkCert) {
    $checkCert | Remove-Item
    Invoke-WebRequest -Headers @{Authorization = "token $($token)"} -Uri "$url" -OutFile C:\Windows\Temp\main.zip
    Expand-Archive -Path C:\Windows\Temp\main.zip -DestinationPath C:\Windows\Temp\ -Force
    
    $pfxPass = Get-Content PATH_TO_PASS_FILE
    $encryptedPass = ConvertTo-SecureString -String $pfxPass -AsPlainText -Force
    $year = (Get-Date).Year
    Import-PfxCertificate C:\Windows\Temp\Certs-main\DOMAIN-$year.pfx -Password $encryptedPass -CertStoreLocation Cert:\LocalMachine\My\
    
    Remove-Item C:\Windows\Temp\Certs-main -Recurse -Force
}
