# Replace 'chocoserver' with the hostname of your CCM server in your environment

# Login
$CcmServerHostname = 'chocoserver'
$Credential = Get-Credential
$body = @{
    usernameOrEmailAddress = $Credential.UserName
    password = $Credential.GetNetworkCredential().Password
}
Invoke-WebRequest -Uri "https://$CcmServerHostname/Account/Login" -Method POST -ContentType 'application/x-www-form-urlencoded' -Body $body -SessionVariable Session -ErrorAction Stop

# Cancel range of deployments
for ($i = 1; $i -le 400; $i++) {
    $body = @"
    {
        "id": $i
    }
"@
    Invoke-WebRequest -Uri "https://$CcmServerHostname/api/services/app/DeploymentPlans/Cancel" -Method POST -WebSession $Session -Body $body -ContentType 'application/json-patch+json'
}
