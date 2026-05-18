$adComputers = Get-ADComputer -filter * -credential $cred | Select-Object -ExpandProperty name 

$adComputers | ForEach-Object -Parallel {

    $online = Test-Connection -ComputerName $_ -Count 1 -Quiet

    [PSCustomObject]@{
        Name      = $_
        Status    = if ($online) { "Online" } else { "Offline" }
        LastCheck = Get-Date -Format "HH:mm"
    }

} -ThrottleLimit 10
