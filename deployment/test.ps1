. ./waitForServersReboot
$invocation = (Get-Variable MyInvocation).Value
$currentDirectory = Split-Path $invocation.MyCommand.Path
$appConfigFile = [IO.Path]::Combine($currentDirectory, 'appConfig.xml')
Write-Debug $appConfigFile

$appConfig = New-Object XML
$appConfig.Load($appConfigFile)

function printVar {
    foreach ($varName in $args){
        Write-Debug ($varName+" : "+ [string](Get-Variable $varName -ValueOnly))
    }
}



#--------- Fetch parameters from appConfig.xml file--------
$netAdaptor1 =  $appConfig.configuration.servers.adapter1
$netAdaptor2 =  $appConfig.configuration.servers.adapter2
$domainName=$appConfig.configuration.domain.domainName
$domainUser = $appConfig.configuration.domain.domainUser
$domainPasswd = $appConfig.configuration.domain.domainPasswd
$ADOU = $appConfig.configuration.domain.OU
$clusterName = $appConfig.configuration.cluster.clusterName
$clusterIp =  $appConfig.configuration.cluster.clusterIp

printVar "netAdaptor1" "netAdaptor2" "domainName" "domainUser" "domainPasswd" "clusterName" "clusterIp" "ADOU"

$servers= $appConfig.configuration.servers.node
$hciServersNameList=@()
foreach ($singleServer in $servers) {
    $hciServersNameList += $singleServer.serverName
    Write-Debug $singleServer.serverName
    Write-Debug $singleServer.ip
    Write-Debug $singleServer.passwd
    Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value $singleServer.ip -Force -Concatenate
}

#https://learn.microsoft.com/en-us/azure-stack/hci/deploy/create-cluster-powershell

#--------- Step 4: Configure host networking ---------
#The script below is to create a fully converged intent that compute/sotrage/management traffic are altogether in both adaptors, it can be changed
#reference link: https://learn.microsoft.com/en-us/azure-stack/hci/deploy/network-atc?tabs=22H2
#Network intent is only needed to be created in one HCI server, it will be applied to all cluster servers
Write-Host "Create fully converged intent using network adaptors $($netAdaptor1) $($netAdaptor2)"
$ScriptBlockContent = {
    $netAdaptor1 = $args[0]
    $netAdaptor2 = $args[1]    
    Add-NetIntent -Name ConvergedIntent -Management -Compute -Storage -AdapterName $netAdaptor1,$netAdaptor2
}
Invoke-Command -ComputerName $hciServersNameList[0] -ScriptBlock $ScriptBlockContent -ArgumentList $netAdaptor1,$netAdaptor2

#--------- Step 6: Enable Storage Spaces Direct ---------