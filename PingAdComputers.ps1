$adcomps = Get-ADComputer -filter * -Credential $cred | Select-Object -ExpandProperty name

# We "capture" the results into a new variable
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

# Now you have a beautiful table
$report | Format-Table -AutoSize