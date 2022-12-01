$myServer1 = "10.106.99.19"
Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value $myServer1 -Force

$user = $myServer1 + "\Administrator"
$myServer1Pass = "!Microsoft*"
$passwd = convertto-securestring -AsPlainText -Force -String $myServer1Pass
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $user,$passwd
#Enter-PSSession -ComputerName $myServer1 -Credential $cred

$numoftry=0;

$servers=@("10.106.99.19","10.106.99.50")

$WaitForRebootCounter=2
while(1){
    $numoftry+=1
    Write-Host "Wait for server rebooting, test #$numoftry/$WaitForRebootCounter"
    $allSuccess=$true

    foreach ($singleServer in $servers) {
        $Result= Test-NetConnection -ComputerName $singleServer -Port 5985 -InformationLevel Quiet
        if(-not $Result){
            $allSuccess=$false
            break
        }
    }

    <#
    foreach ($singleServer in $servers) {
        $job=Start-Job -ScriptBLock {Test-NetConnection -ComputerName $singleServer -Port 5985 -InformationLevel Quiet}
        $Results = Receive-Job $job -Wait
        Write-Host $singleServer $Results
        if(-not $Results){
            Write-Host $singleServer " test not success, repeat"
            $allSuccess=$false
            break
        }
    }
    #>
    if($allSuccess) {break}
    if($numoftry -ge $WaitForRebootCounter){
        Write-Host "$singleServer can not be reached. Task is interrupted with error."
        exit 1
    }
}

Write-Host "finish"

