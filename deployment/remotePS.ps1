$myServer1 = "10.106.99.19"
Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value $myServer1 -Force

$user = $myServer1 + "\Administrator"
$myServer1Pass = "!Microsoft*"
$passwd = convertto-securestring -AsPlainText -Force -String $myServer1Pass
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $user,$passwd
Enter-PSSession -ComputerName $myServer1 -Credential $cred
