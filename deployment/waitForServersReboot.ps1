function waitForServersReboot([string[]]$hciServersIPList){
    Write-Host "Wait for all servers finish rebooting..."
    Start-Sleep -Seconds 2 #pause a short while so servers have started rebooting after domain registration
    $indexOfOnlineCheck=0;
    $maxOnlineCheck=20
    while(1){
        $indexOfOnlineCheck+=1
        Write-Debug "Check #$indexOfOnlineCheck/$maxOnlineCheck"
        $allSuccess=$true
        foreach ($singleServerIP in $hciServersIPList) {
            $Result= Test-NetConnection -ComputerName $singleServerIP -Port 5985 -InformationLevel Quiet
            if(-not $Result){
                $allSuccess=$false
                break
            }
        }
        if($allSuccess) {break}
        if($indexOfOnlineCheck -ge $maxOnlineCheck){
            Write-Host "$singleServerIP can not be reached. Task is interrupted with error."
            Return 1
        }
    }
    Write-Host "All servers are back online. Continue..."
    Return 0
}