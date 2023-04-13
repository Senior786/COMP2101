$choice=$args[0]

function SystemHardware {
    $hardware = Get-CimInstance Win32_ComputerSystem
    [pscustomobject]@{
        "Manufacturer" = $hardware.Manufacturer
        "Model" = $hardware.Model
        "Serial Number" = $hardware.Serial
        "System Type" = $hardware.SystemType
        "Total Physical Memory" = "{0:N2} GB" -f ($hardware.TotalPhysicalMemory / 1GB)
    }
}

function OperatingSystem {
    $os = Get-CimInstance Win32_OperatingSystem
    [pscustomobject]@{
        "Operating System" = $os.Caption
        "Version" = $os.Version
        "Build Number" = $os.BuildNumber
        "Service Pack" = $os.ServicePackMajorVersion
    }
}

function Processor {
    $processor = Get-CimInstance Win32_Processor
    $cores = $processor.NumberOfCores
    $threads = $processor.NumberOfLogicalProcessors - $cores
    [pscustomobject]@{
        "Processor" = $processor.Name
        "Speed" = "{0:N2} GHz" -f ($processor.MaxClockSpeed / 1e9)
        "Cores" = "$($cores) physical, $($threads) logical"
        "L1 Cache" = "$([math]::Round($processor.L2CacheSize / 1KB)) KB" # Rounded the value and added the unit 'KB'
        "L2 Cache" = "$([math]::Round($processor.L3CacheSize / 1KB)) KB" # Rounded the value and added the unit 'KB'
        "L3 Cache" = "$([math]::Round($processor.L3CacheSize / 1MB)) MB" # Rounded the value and added the unit 'MB'
    }
}


function Memory {
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
        $result=Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, MacAddress, LinkSpeed, MediaType, DriverVersion | Format-Table -AutoSize
    return $result
}




#checking the choice and displaying the result

if ($choice -eq "System") {
#displays result 
Write-Output "  "
Write-Output "  "
Write-Output "SYSTEM INFORMATION REPORT" 


Write-Output "RETRIEVED HARDWARE DATA"
SystemHardware | Format-List

Write-Output "RETRIEVED OPERATING SYSTEM DATA"
OperatingSystem | Format-List

Write-Output "RETRIEVED PROCESSOR DATA"
Processor  | Format-List

Write-Output "  "
Write-Output "RETRIEVED MEMORY DATA"
Memory 

}

elseif ($choice -eq "Disks") {
#displays result for disk
Write-Output "  "
Write-Output "  "
Write-Output "SYSTEM INFORMATION REPORT"
Write-Output "RETRIVED DISK DATA"
Disk | Format-Table -AutoSize

Write-Output "  "
Write-Output "END OF REPORT"
}

elseif ($choice -eq "Network") {
#displays results for network
Write-Output "  "
Write-Output "  "
Write-Output "SYSTEM INFORMATION REPORT" 

Write-Output "RETRIEVED IP DATA"
IPConfig.ps1


Write-Output "  "
Write-Output "END OF REPORT"
}

else{
#displays the result for the default
Write-Output "  "
Write-Output "  "
Write-Output "SYSTEM INFORMATION REPORT" 


Write-Output "RETRIEVED HARDWARE DATA"
SystemHardware | Format-List

Write-Output "RETRIEVED OPERATING SYSTEM DATA"
OperatingSystem | Format-List

Write-Output "RETRIEVED PROCESSOR DATA"
Processor 

Write-Output "  "
Write-Output "RETRIEVED RAM MEMORY DATA"
Memory 


Write-Output "  "
Write-Output "RETRIEVED DISK DRIVE DATA"
Disk | Format-Table -AutoSize

Write-Output "  "
Write-Output "RETRIEVED NETWORK DATA"
Network


Write-Output "RETRIEVED IP DATA"
IPConfig.ps1


Write-Output "  "
Write-Output "END OF REPORT"
}