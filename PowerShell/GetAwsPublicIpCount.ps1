$region = @(
    "REGIONS"
)

foreach ($r in $region) {
    $instanceCount = (Get-EC2Instance -Filter @{name='ip-address'; values="*"} -Region $r).Instances.Count
    $instanceTotal += $instanceCount
    $lbCount = (Get-ELB2LoadBalancer -Region $r).Count
    $lbTotal += $lbCount
}
$pubTotal = $instanceTotal+$lbTotal
Write-Host "Total instances with public IP addresses: $instanceTotal
Total load balancers: $lbTotal
Total public IPs: $pubTotal"
