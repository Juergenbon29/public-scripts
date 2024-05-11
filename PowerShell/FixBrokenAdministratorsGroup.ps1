# There's a bug with the 'Get-LocalGroupMember -Group Administrators' that returns an error when looking for old AD admins cached on the local computer missing SIDs. This should fix that issue

$administrators = @(
    ([ADSI]"WinNT://./Administrators").psbase.Invoke('Members') | ForEach-Object { 
        $_.GetType().InvokeMember('AdsPath','GetProperty',$null,$($_),$null) 
    }
) -match '^WinNT';

$administrators = $administrators -replace "WinNT://",""

$administrators

foreach ($administrator in $administrators) {

    if ($administrator -like "$env:ComputerName/*") {
        continue;
    }
    Write-Host "$administrator will be removed from 'Administrators'"
    Remove-LocalGroupMember -group "administrators" -member $administrator
}