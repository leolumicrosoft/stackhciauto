function fetchConfigParameters() {
    $currentDirectory =  Get-Location
    $appConfigFile = [IO.Path]::Combine($currentDirectory, 'appConfig.xml')
    Write-Debug $appConfigFile

    $appConfig = New-Object XML
    $appConfig.Load($appConfigFile)

    function printVar {
        foreach ($varName in $args) {
            Write-Debug ($varName + " : " + [string](Get-Variable $varName -ValueOnly))
        }
    }



    #--------- Fetch parameters from appConfig.xml file--------
    $global:netAdaptor1 = $appConfig.configuration.servers.adapter1
    $global:netAdaptor2 = $appConfig.configuration.servers.adapter2
    $global:domainName = $appConfig.configuration.domain.domainName
    $global:domainUser = $appConfig.configuration.domain.domainUser
    $global:domainPasswd = $appConfig.configuration.domain.domainPasswd
    $global:ADOU = $appConfig.configuration.domain.OU
    $global:clusterName = $appConfig.configuration.cluster.clusterName
    $global:clusterIp = $appConfig.configuration.cluster.clusterIp
    $global:storagePoolName = $appConfig.configuration.cluster.storagePoolName
    $global:volumeName = $appConfig.configuration.cluster.volumeName
    $global:volumeSize = $appConfig.configuration.cluster.volumeSize 
    $global:proxyServer = $appConfig.configuration.httpProxy.server 
    $global:proxyBypassList = $appConfig.configuration.httpProxy.bypassList 
        
    printVar "netAdaptor1" "netAdaptor2" "domainName" "domainUser" "domainPasswd" "clusterName" "clusterIp" "ADOU" "volumeName" "volumeSize" "storagePoolName"

    $global:servers = $appConfig.configuration.servers.node
    $global:hciServersNameList = @()
    $global:hciServersIPList=@()
    foreach ($singleServer in $global:servers) {
        $global:hciServersNameList += $singleServer.serverName
        $global:hciServersIPList += $singleServer.ip
        Write-Debug $singleServer.serverName
        Write-Debug $singleServer.ip
        Write-Debug $singleServer.passwd
        Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value $singleServer.ip -Force -Concatenate
    }
}