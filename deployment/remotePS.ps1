$myServer1 = "WIN-SPD2BH8H94O"
$myServer2 = "WIN-KVL370N900H"

Enter-PSSession -ComputerName $myServer2

#$session = New-PSSession -ComputerName $myServer2
#Copy-Item -Path "C:\Users\Administrator.MICROSOFT\AppData\Local\Temp\Validation Report 2022.12.06 At 18.15.40.htm" -Destination "C:\stackhciauto" -FromSession $session

#$hciServersNameList = "WIN-SPD2BH8H94O", "WIN-KVL370N900H"
#New-Cluster -Name "HPELab1" -Node $hciServersNameList -nostorage -StaticAddres "10.106.100.100"
#Test-Cluster -Include "Storage Spaces Direct", "Inventory", "Network", "System Configuration"

