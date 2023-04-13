function IPConfig
{
    $adapters = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled -eq $true}

    $table = @()

    foreach ($adapter in $adapters) {
        $ipAddresses = $adapter.IPAddress -join ', '
        $subnetMasks = $adapter.IPSubnet -join ', '
        $dnsDomain = $adapter.DNSDomain
        $dnsServers = $adapter.DNSServerSearchOrder -join ', '
        
        $table += [pscustomobject]@{
            "Adapter Description" = $adapter.Description
            "Index" = $adapter.Index
            "IP Address(es)" = $ipAddresses
            "Subnet Mask(s)" = $subnetMasks
            "DNS Domain Name" = $dnsDomain
            "DNS Server(s)" = $dnsServers
        }
    }

    $table | Format-Table -AutoSize
}

IPConfig