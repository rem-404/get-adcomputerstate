$adcomps = Get-ADComputer -filter * -Credential $cred | Select-Object -ExpandProperty name

$report = foreach ($pc in $adcomps) {
    if (Test-Connection -ComputerName $pc -Count 1 -Quiet) {
        [PSCustomObject]@{
            ComputerName = $pc
            Status       = "Online"
            LastCheck    = Get-Date -Format "HH:mm"
        }
    } else {
        [PSCustomObject]@{
            ComputerName = $pc
            Status       = "OFFLINE"
            LastCheck    = Get-Date -Format "HH:mm"
        }
    }
}

# Or you can pipe the result to something usefull
$report | Format-Table -AutoSize
