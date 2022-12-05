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
$hciServersIPList=@()
foreach ($singleServer in $servers) {
    $hciServersNameList += $singleServer.serverName
    $hciServersIPList += $singleServer.ip
    Write-Debug $singleServer.serverName
    Write-Debug $singleServer.ip
    Write-Debug $singleServer.passwd
    Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value $singleServer.ip -Force -Concatenate
}

#https://learn.microsoft.com/en-us/azure-stack/hci/deploy/create-cluster-powershell
