#System hardware
function SystemHardware 
{
    $hardware = Get-CimInstance Win32_ComputerSystem
    [pscustomobject]@{
        "Manufacturer" = $hardware.Manufacturer
        "Model" = $hardware.Model
        "Serial Number" = $hardware.Serial
        "System Type" = $hardware.SystemType
        "Total Physical Memory" = "{0:N2} GB" -f ($hardware.TotalPhysicalMemory / 1GB)
    }
}

#Operating System
function OperatingSystem 
{
    $os = Get-CimInstance Win32_OperatingSystem
    [pscustomobject]@{
        "Operating System" = $os.Caption
        "Version" = $os.Version
        "Build Number" = $os.BuildNumber
        "Service Pack" = $os.ServicePackMajorVersion
    }
}

#Processor
function Processor 
{
    $processor = Get-CimInstance Win32_Processor
    $co…
[12:02 a.m., 2023-04-13] Shabista: function welcome
{
	write-output "Welcome to planet $env:computername Overlord $env:username" 
	$now = get-date -format 'HH:MM tt on dddd' 
	write-output "It is $now." 
}

function Get-CPUInfo {
    $cpus = Get-CimInstance CIM_Processor

    foreach ($cpu in $cpus) {
        [PSCustomObject]@{
            "Manufacturer" = $cpu.Manufacturer
            "Model" = $cpu.Name
            "Cores" = $cpu.NumberOfCores
            "Current Speed (GHz)" = "{0:F2}" -f ($cpu.CurrentClockSpeed / 1e9)
            "Max Speed (GHz)" = "{0:F2}" -f ($cpu.MaxClockSpeed / 1e9)
        }
    }
}

function Get-MyDisks {
    $disks = Get-CimInstance Win32_DiskDrive | Select-Object Manufacturer,Model,SerialNumber,FirmwareRevision,@{Name="Size (GB)";Expression={$_.Size/1GB}}
    $d…
[12:03 a.m., 2023-04-13] Shabista: function IPConfig
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

#System hardware
function SystemHardware 
{
    $hardware = Get-CimInstance Win32_ComputerSystem
    [pscustomobject]@{
        "Manufacturer" = $hardware.Manufacturer
        "Model" = $hardware.Model
        "Serial Number" = $hardware.Serial
        "System Type" = $hardware.SystemType
        "Total Physical Memory" = "{0:N2} GB" -f ($hardware.TotalPhysicalMemory / 1GB)
    }
}

#Operating System
function OperatingSystem 
{
    $os = Get-CimInstance Win32_OperatingSystem
    [pscustomobject]@{
        "Operating System" = $os.Caption
        "Version" = $os.Version
        "Build Number" = $os.BuildNumber
        "Service Pack" = $os.ServicePackMajorVersion
    }
}

#Processor
function Processor 
{
    $processor = Get-CimInstance Win32_Processor
    $cores = $processor.NumberOfCores
    $threads = $processor.NumberOfLogicalProcessors - $cores

    # Used '1GHz' in place of '(1GB * 1GHz)' which was causing the error
    [pscustomobject]@{
        "Processor" = $processor.Name
        "Speed" = "{0:N2} GHz" -f ($processor.MaxClockSpeed / 1e9)
        "Cores" = "$($cores) physical, $($threads) logical"
        "L1 Cache" = "$([math]::Round($processor.L2CacheSize / 1KB)) KB" # Rounded the value and added the unit 'KB'
        "L2 Cache" = "$([math]::Round($processor.L3CacheSize / 1KB)) KB" # Rounded the value and added the unit 'KB'
        "L3 Cache" = "$([math]::Round($processor.L3CacheSize / 1MB)) MB" # Rounded the value and added the unit 'MB'
    }
}

#Memory
function Memory 
{
    $memory = Get-CimInstance Win32_PhysicalMemory
    $totalMemory = ($memory.Capacity | Measure-Object -Sum).Sum
    $table = foreach ($dim in $memory) {
        [pscustomobject]@{
            "Vendor" = $dim.Manufacturer
            "Description" = $dim.PartNumber
            "Capacity" = "{0:N2} GB" -f ($dim.Capacity / 1GB)
            "Bank" = $dim.BankLabel
            "Slot" = $dim.DeviceLocator
        }
    }

    [pscustomobject]@{
        "RAM Installed" = $table
        "Total RAM" = "{0:N2} GB" -f ($totalMemory / 1GB)
    }
}

#Disk
function Disk 
{
    $diskdrives = Get-CimInstance CIM_DiskDrive
    $table = foreach ($disk in $diskdrives) {
        $partitions = $disk | Get-CimAssociatedInstance -ResultClassName CIM_DiskPartition
        foreach ($partition in $partitions) {
            $logicaldisks = $partition | Get-CimAssociatedInstance -ResultClassName CIM_LogicalDisk
            foreach ($logicaldisk in $logicaldisks) {
                $freeSpaceGB = "{0:N2} GB" -f ($logicaldisk.FreeSpace / 1GB)
                $sizeGB = "{0:N2} GB" -f ($logicaldisk.Size / 1GB)
                [PSCustomObject]@{
                    "Disk" = $disk.DeviceID
                    "Partition" = $partition.Name
                    "DriveLetter" = $logicaldisk.DeviceID
                    "Size" = $sizeGB
                    "FreeSpace" = $freeSpaceGB
                }
            }
        }
    }
    return $table
}

#Network
function Network
{
    Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, MacAddress, LinkSpeed, MediaType, DriverVersion
}


Write-Host "---------------------- System Information ----------------------`n"

Write-Host "`nSystem Hardware:"
SystemHardware

Write-Host "`nOperating System:"
OperatingSystem

Write-Host "`nProcessor:"
Processor

Write-Host "`nMemory:"
Memory

Write-Host "`nDisk:"
Disk

Write-Host "`nNetwork:"
Network

Write-Host "`n---------------------- End of System Information ----------------------"



Export-ModuleMember -Function IPConfig, SystemHardware, OperatingSystem, Processor, Memory, Disk, Network
