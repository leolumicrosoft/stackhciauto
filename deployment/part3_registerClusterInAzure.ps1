. ./fetchConfigParameters
fetchConfigParameters  #read config parameters from appConfig.xml file

#https://learn.microsoft.com/en-us/azure-stack/hci/deploy/create-cluster-powershell

#-------- Register HCI cluster with Azure ---------
Register-AzStackHCI  -SubscriptionId  "azure subscription id"  -ComputerName $hciServersNameList[0] -ResourceGroupName "azure resouce group name" -UseDeviceAuthentication