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
printVar "netAdaptor1" "netAdaptor2" "domainName" "domainUser" "domainPasswd"


$servers= $appConfig.configuration.servers.node
foreach ($singleServer in $servers) {
    Write-Debug $singleServer.name
    Write-Debug $singleServer.serverName
    Write-Debug $singleServer.passwd
}


#https://learn.microsoft.com/en-us/azure-stack/hci/deploy/create-cluster-powershell
#--------- Step 1.2: Join the domain and add domain accounts --------

<#

# ---- for server 1 ------------------------------------------------

# Step 1.2: Join the domain and add domain accounts

Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value $myServer1 -Force

$user = $myServer1 + "\Administrator"
$passwd = convertto-securestring -AsPlainText -Force -String $myServer1Pass
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $user,$passwd
# Enter-PSSession -ComputerName $myServer1 -Credential $cred

$ScriptBlockContent = {
    $domainName = $args[0]
    $domainUser = $args[1]
    $domainPasswd = $args[2]

    $dPass = convertto-securestring -AsPlainText -Force -String $domainPasswd
    $credDomain = new-object -typename System.Management.Automation.PSCredential -argumentlist $domainUser,$dPass
    (Add-Computer -DomainName $domainName -Credential $credDomain -Restart -Force)
}
Invoke-Command -ComputerName $myServer1 -Credential $cred -ScriptBlock $ScriptBlockContent -ArgumentList $domainName,$domainUser,$domainPasswd

<#
$ScriptBlockContent = {
    (get-netadapter | Format-List -Property "Name", "ifDesc","SystemName","DriverDescription","Status" )
}
Invoke-Command -ComputerName $myServer1 -Credential $cred -ScriptBlock $ScriptBlockContent 
#>
#>