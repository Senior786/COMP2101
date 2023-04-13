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

function Memory 
{
    $memory = Get-CimInstance Win32_PhysicalMemory
    $capacity_sum = 0
    $table = foreach ($dim in $memory) {
        $capacity_gb = $dim.Capacity / 1GB
        $capacity_sum += $capacity_gb
        [pscustomobject]@{
            "Vendor" = $dim.Manufacturer
            "Description" = $dim.PartNumber
            "Capacity" = "{0:N2} GB" -f $capacity_gb
            "Bank" = $dim.BankLabel
            "Slot" = $dim.DeviceLocator
        }
    }

    [pscustomobject]@{
        "RAM Installed" = $table
        "Total RAM" = "{0:N2} GB" -f $capacity_sum
    }
}

#Memory
function Memory 
{
    $memory = Get-CimInstance Win32_PhysicalMemory
    $capacity_sum = 0
    $table = foreach ($dim in $memory) {
        $capacity_gb = $dim.Capacity / 1GB
        $capacity_sum += $capacity_gb
        [pscustomobject]@{
            "Vendor" = $dim.Manufacturer
            "Description" = $dim.PartNumber
            "Capacity" = "{0:N2} GB" -f $capacity_gb
            "Bank" = $dim.BankLabel
            "Slot" = $dim.DeviceLocator
        }
    }

    $output = [pscustomobject]@{
        "RAM Installed" = $table
        "Total RAM" = "{0:N2} GB" -f $capacity_sum
    }

    $outputdata | Format-Table -AutoS}

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

Write-Output "System Hardware"
SystemHardware | Format-List

Write-Output "Operating System"
OperatingSystem | Format-List


Write-Output "Processor"
Processor | Format-List


Write-Output "Memory"
Memory

Write-Output "Disk"
Disk | Format-Table -AutoSize


Write-Output "Network"
Network

Write-Host "`n---------------------- End of System Information ----------------------"