# Typically, you manage VMs from a remote computer, rather than on a host server in a cluster. This remote computer is called the management computer

Write-Host "Creating VM ..."

#get vSwitch name by running Get-VMSwitch in hci node server
New-VM -ComputerName WIN-SPD2BH8H94O -Name VM1 -MemoryStartupBytes 2GB -BootDevice VHD -NewVHDPath "C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks\$vmName.vhdx" -Path .\VMData -NewVHDSizeBytes 10GB -Generation 2 -Switch "ConvergedSwitch(convergedintent)"
Get-VM -ComputerName VM1
Start-VM -Name VM1