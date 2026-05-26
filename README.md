# Get-ADComputerState
*This script is for a lab environment and meant for learning purposes only*

## What does it do
Pulls all computer accounts from Active Directory and checks their connectivity in parallel, returning a clean object per machine with:

Computer name
Status (Online / Offline / Error)
Time of last check

Runs all ping checks simultaneously instead of one by one so it doesn't take forever on larger environments.
What does it solve
Manually pinging machines or checking AD one by one is slow and gives you no structured output to work with. This gives you a quick snapshot of your entire AD computer inventory in one shot, with output you can filter and pipe into other tools.

## Who's it for
Sysadmins who want a fast network inventory check without clicking around or waiting on sequential pings. Works well as a first step before running remote commands — filter for Online machines first, then target them.


## Requirements
PowerShell 7+ (required for ForEach-Object -Parallel)
ActiveDirectory module (RSAT)
Credentials with read access to Active Directory — the function will prompt via Get-Credential if $Credential isn't already set in your session
Works best when paired with a PowerShell profile that pre-loads $Credential for seamless use

```
Usage
powershell# Basic usage
Get-ADComputerState

# Filter online machines only
Get-ADComputerState | Where-Object { $_.Status -eq "Online" }

# Pipe into remote commands
Get-ADComputerState | Where-Object { $_.Status -eq "Online" } | ForEach-Object { 
    Invoke-Command -ComputerName $_.Name -ScriptBlock { Get-ExecutionPolicy } 
}
```

## Warning
ForEach-Object -Parallel runs up to 10 threads simultaneously (ThrottleLimit 10) — adjust based on your environment size and network capacity
-ErrorAction Stop is required inside the parallel block for try/catch to work — this is a known PowerShell parallel runspace behavior
$Credential uses $using: scope pattern internally — if you modify the parallel block, keep this in mind

## Limitations
No filtering by OU — pulls all computer accounts from the entire directory
Offline status just means no ping response — could be firewall rules, not necessarily powered off
Error status returns the raw exception message which can be long and truncated in the console
ThrottleLimit is hardcoded — not currently a parameter

## Notes
Work in progress — OU filtering and ThrottleLimit as parameters coming in a future iteration.

## Sample Output
```
<#
OUTPUT SAMPLE
PS C:\Logs> Get-ADComputerState

Name          Status  LastCheck
----          ------  ---------
DC01          Online  11:29
A8-7600-1     Online  11:29
THINKPAD-T470 Online  11:29
DC02          Online  11:29
VM-WINDOWS11  Offline 11:29
VM-WINDOWS10  Offline 11:29

PS C:\Logs>

With Error returned (deliberate error to check catch logic)
PS C:\Logs> Get-ADComputerState

Name          Status
----          ------
A8-7600-1     Error: The term 'XX$online' is not recognized as a name of a cmdlet, function, script file, or execut…
DC01          Error: The term 'XX$online' is not recognized as a name of a cmdlet, function, script file, or execut…
VM-WINDOWS11  Error: The term 'XX$online' is not recognized as a name of a cmdlet, function, script file, or execut…
THINKPAD-T470 Error: The term 'XX$online' is not recognized as a name of a cmdlet, function, script file, or execut…
DC02          Error: The term 'XX$online' is not recognized as a name of a cmdlet, function, script file, or execut…
VM-WINDOWS10  Error: The term 'XX$online' is not recognized as a name of a cmdlet, function, script file, or execut…

PS C:\Logs>
#>
```
