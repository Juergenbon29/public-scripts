# Forces logout of admin accounts with a warning dialog if logged in

$getUser = Get-WMIObject -class Win32_ComputerSystem | Select-Object username

$username = $getuser.username.Split('\')[1]

if ($username -eq 'ADMIN' -or $username -eq 'ADMIN') {
    Write-Host "Logged in user is 'ADMIN' or 'ADMIN', exiting"
    exit 
} 

elseif (Get-LocalGroupMember -Group Administrators -Member $username) {
    # Warning dialog
    msg $username /time:59 "You are logged into an administrator account which is not allowed in our environment, you will be logged out in 60 seconds. Please log back in with your normal account"
    Start-Sleep -Seconds 60

    # Force logout
    $sessionId = ((quser | Where-Object { $_ -match "$username" }) -split ' +')[2]
    logoff $sessionId

    # Send alert to SOC Slack channel
    $message = @"
{
    "attachments": [
        {
            "fallback": "Windows admin user login detected on $(hostname): $username has been forced to log out",
            "color": "warning",
            "title": "Windows admin user login detected on $(hostname): $username has been forced to log out",
            "text": "Please follow up with this user if necessary"
        }
    ]
}
"@

    Invoke-RestMethod -Method Post -Uri "YOUR_WEBHOOK_URL" -Body $message -ContentType "application/json" | Out-Null
} 
else {
    Write-Host "$username is not an admin, exiting"
    exit 
}