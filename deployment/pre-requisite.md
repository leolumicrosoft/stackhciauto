#### Prepare AD Domain controller

#### Prepare management PC 

- Prepare a windows management server that is in same subnet with your 2 Stack HCI physical servers.
- Install Azure powershell
```
https://learn.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-8.3.0
```
- Update management PC to the latest OS patch
- Install powershell module in managment PC
  Command: Add-WindowsFeature RSAT-Clustering-PowerShell


#### HCI Server  

- HCI OS ready
- DNS in each HCI server must be set correctly so they can reach domain server by domain name.
  Sample command(in each HCI server): netsh interface ip set dns name="yournetadaptorname" static 10.106.99.6
  where in the sample 10.106.99.6 is the domain controller IP address

#### Prepare Azure account 

- Prepare your own Azure account with proper authorization to create new role, and do role assignment.


#### Other preparation work:
- Management PC can connect with HCI servers by port 5985, which is used for remote management service
  Verification sample command(in management PC): test-netconnection yourHCIServerIP -port 5985




