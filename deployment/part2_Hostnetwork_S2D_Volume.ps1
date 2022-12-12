. ./fetchConfigParameters
fetchConfigParameters  #read config parameters from appConfig.xml file

#https://learn.microsoft.com/en-us/azure-stack/hci/deploy/create-cluster-powershell
#--------- Step 4: Configure host networking ---------
#The script below is to create a fully converged intent that compute/sotrage/management traffic are altogether in both adaptors, it can be changed
#reference link: https://learn.microsoft.com/en-us/azure-stack/hci/deploy/network-atc?tabs=22H2
Write-Host "Create fully converged intent using network adaptors $($netAdaptor1) $($netAdaptor2)"
$ScriptBlockContent = {
    $netAdaptor1 = $args[0]
    $netAdaptor2 = $args[1]    
    Add-NetIntent -Name ConvergedIntent -Management -Compute -Storage -AdapterName $netAdaptor1,$netAdaptor2
}
#Only needed to execute in one HCI server, it will be applied to all cluster servers
Invoke-Command -ComputerName $hciServersNameList[0] -ScriptBlock $ScriptBlockContent -ArgumentList $netAdaptor1,$netAdaptor2

#--------- Step 6: Enable Storage Spaces Direct ---------
$ScriptBlockContent = {
    $storagePoolName = $args[0]
    Enable-ClusterStorageSpacesDirect -PoolFriendlyName $storagePoolName -Confirm:$false
    Get-StoragePool
}
#Only needed to execute in one HCI server, it will be applied to all cluster servers
Invoke-Command -ComputerName $hciServersNameList[0] -ScriptBlock $ScriptBlockContent -ArgumentList $storagePoolName


#-------- create cluster volume ---------
$ScriptBlockContent = {
    $volumeName = $args[0]
    $volumeSize = $args[1]
    $storagePoolName= $args[2]
    New-Volume -FriendlyName $volumeName -FileSystem CSVFS_ReFS -StoragePoolFriendlyName $storagePoolName -Size $volumeSize
}
#Only needed to execute in one HCI server, it will be applied to all cluster servers
Invoke-Command -ComputerName $hciServersNameList[0] -ScriptBlock $ScriptBlockContent -ArgumentList $volumeName $volumeSize $storagePoolName
