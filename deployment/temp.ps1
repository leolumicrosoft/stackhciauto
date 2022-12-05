. ./waitForServersReboot
$invocation = (Get-Variable MyInvocation).Value
$currentDirectory = Split-Path $invocation.MyCommand.Path
$appConfigFile = [IO.Path]::Combine($currentDirectory, 'appConfig.xml')

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
$clusterName = $appConfig.configuration.cluster.clusterName
$clusterIp =  $appConfig.configuration.cluster.clusterIp

$servers= $appConfig.configuration.servers.node
$hciServersNameList=@()
foreach ($singleServer in $servers) {
    $hciServersNameList += $singleServer.serverName
    Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value $singleServer.serverName -Force -Concatenate
}

write-host $hciServersNameList