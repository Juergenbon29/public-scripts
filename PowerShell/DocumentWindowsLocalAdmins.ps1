# Detects admin users on Windows and sends a Slack message to #asset-assignments

$getUser = Get-WMIObject -class Win32_ComputerSystem | Select-Object username

$username = $getuser.username.Split('\')[1]

$adminUsers = (Get-LocalGroupMember -Group Administrators).Name 2>$null

if ($adminUsers -like "$env:ComputerName\$username*") {
    $adminName = $adminUsers.Split('\')
    $message = @"
{
    "attachments": [
        {
            "fallback": "$username has a Windows admin account on $(hostname)",
            "color": "warning",
            "title": "$username has a Windows admin account on $(hostname)",
            "text": "Admin account name: $($adminName | Where-Object { $_ -like "$username*" })"
        }
    ]
}
"@
    Invoke-RestMethod -Method Post -Uri "YOUR_WEBHOOK_URL" -Body $message -ContentType "application/json" | Out-Null
}
else {
    Write-Host "No user admin accounts found on this device"
}
