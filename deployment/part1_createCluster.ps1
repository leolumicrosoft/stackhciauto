. ./waitForServersReboot
. ./fetchConfigParameters
fetchConfigParameters  #read config parameters from appConfig.xml file

#https://learn.microsoft.com/en-us/azure-stack/hci/deploy/create-cluster-powershell
<#
Preparation work:
- Management PC can connect with HCI servers by port 5985, which is used for remote management service
  Verification sample command(in management PC): test-netconnection yourHCIServerIP -port 5985

- Install powershell module in managment PC
  Command: Add-WindowsFeature RSAT-Clustering-PowerShell

- DNS in each HCI server must be set correctly so they can reach domain server by domain name.
  Sample command(in each HCI server): netsh interface ip set dns name="yournetadaptorname" static 10.106.99.6
  where in the sample 10.106.99.6 is the domain controller IP address

- Update management PC to the latest OS patch

- AD Organization Unit: If not yet, create a AD organization unit that all HCI servers will be added into.
#>

#--------- Step 1.2: Join the domain and add domain accounts --------


$needWaitForRestart=$false
foreach ($singleServer in $servers) {  #before server being added to domain, the script use server ip address instead of server name as DNS may not recognize the name yet
    $user = $singleServer.ip + "\Administrator"
    $passwd = convertto-securestring -AsPlainText -Force -String $singleServer.passwd
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $user,$passwd

    $ScriptBlockContent = {
        $domainName = $args[0]
        $domainUser = $args[1]
        $domainPasswd = $args[2]
    
        $dPass = convertto-securestring -AsPlainText -Force -String $domainPasswd
        $credDomain = new-object -typename System.Management.Automation.PSCredential -argumentlist $domainUser,$dPass
        $currentDomain= (Get-ComputerInfo).CsDomain
        if($currentDomain -eq $domainName){
            Write-Host "It belongs to domain. Skip.."
            Return $false
        }else{
            Add-Computer -DomainName $domainName -OUPath $ADOU -Credential $credDomain -Restart -Force
            Return $true
        }
    }
    Write-Host "Register server $($singleServer.serverName) to domain $($domainName), then restart..."
    $execResult= (Invoke-Command -ComputerName $singleServer.ip -Credential $cred -ScriptBlock $ScriptBlockContent -ArgumentList $domainName,$domainUser,$domainPasswd)
    if($execResult) {$needWaitForRestart=$true}
}


if($needWaitForRestart) {  
    $execResult = (waitForServersReboot $hciServersIPList)
    if( $execResult -ne 0 ) {exit 1} 
}

#enable Administrative priviledge to HCI servers by adding management PC domain admin user to local Administrators group of each HCI server
foreach ($singleServer in $servers) {  #before server being added to domain, the script use server ip address instead of server name as DNS may not recognize the name yet
    $user = $singleServer.ip + "\Administrator"
    $passwd = convertto-securestring -AsPlainText -Force -String $singleServer.passwd
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $user,$passwd

    $ScriptBlockContent = {
        $domainUser = $args[0]
        Add-LocalGroupMember -Group "Administrators" -Member $domainUser
    }
    Write-Host "Add domain administrator to local administrators group of server $($singleServer.serverName)"
    (Invoke-Command -ComputerName $singleServer.ip -Credential $cred -ScriptBlock $ScriptBlockContent -ArgumentList $domainUser)
}
# From here above, there is no need to specify HCI server credential because domain user has been added to each HCI server's "administrators" group


$needWaitForRestart=$false
foreach ($singleServer in $servers) {
    #--------- Step 1.3: Install roles and features ---------
    Write-Host "Install roles and features in $($singleServer.serverName), then restart if there is change..."
    $ScriptBlockContent = {
        $execResult= (Install-WindowsFeature -Name "BitLocker", "Data-Center-Bridging", "Failover-Clustering", "FS-FileServer", "FS-Data-Deduplication", "Hyper-V", "Hyper-V-PowerShell", "RSAT-AD-Powershell", "RSAT-Clustering-PowerShell", "NetworkATC", "Storage-Replica" -IncludeAllSubFeature -IncludeManagementTools)
        if($execResult.RestartNeeded -eq "Yes") {
            Restart-Computer -WSManAuthentication Kerberos -Force
            Return $true
        }else{
            Write-Host "There is no change."
            Return $false
        }
    }
    $execResult= (Invoke-Command -ComputerName $singleServer.serverName -ScriptBlock $ScriptBlockContent)
    if($execResult) {$needWaitForRestart=$true}
}


if($needWaitForRestart) {  
    $execResult = (waitForServersReboot $hciServersIPList)
    if( $execResult -ne 0 ) {exit 1} 
}


#--------- Step 2: Prep for cluster setup ---------
#--------- Step 2.1: Prepare drives ---------
foreach ($singleServer in $servers) {
    Write-Host "Prepare drives for $($singleServer.serverName)"
    $ScriptBlockContent = {
        Update-StorageProviderCache
        Get-StoragePool | ? IsPrimordial -eq $false | Set-StoragePool -IsReadOnly:$false -ErrorAction SilentlyContinue
        Get-StoragePool | ? IsPrimordial -eq $false | Get-VirtualDisk | Remove-VirtualDisk -Confirm:$false -ErrorAction SilentlyContinue
        Get-StoragePool | ? IsPrimordial -eq $false | Remove-StoragePool -Confirm:$false -ErrorAction SilentlyContinue
        Get-PhysicalDisk | Reset-PhysicalDisk -ErrorAction SilentlyContinue
        Get-Disk | ? Number -ne $null | ? IsBoot -ne $true | ? IsSystem -ne $true | ? PartitionStyle -ne RAW | % {
            $_ | Set-Disk -isoffline:$false
            $_ | Set-Disk -isreadonly:$false
            $_ | Clear-Disk -RemoveData -RemoveOEM -Confirm:$false
            $_ | Set-Disk -isreadonly:$true
            $_ | Set-Disk -isoffline:$true
        }
        Get-Disk | Where Number -Ne $Null | Where IsBoot -Ne $True | Where IsSystem -Ne $True | Where PartitionStyle -Eq RAW | Group -NoElement -Property FriendlyName
    }
    Invoke-Command -ComputerName $singleServer.serverName -ScriptBlock $ScriptBlockContent
}


#--------- Step 2.2: Test cluster configuration (Skip in this automation script)--------

#--------- Step 3: Create the cluster--------
Write-Host "Step 3: Create the cluster ... "
New-Cluster -Name $clusterName -Node $hciServersNameList -nostorage -StaticAddres $clusterIp


#To verify cluster creation status, you may check in each cluster server with command: Get-Cluster -Name "yourclustername" | Get-ClusterResource