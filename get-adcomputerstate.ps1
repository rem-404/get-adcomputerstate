<#
Get all adcomputer -> returns a simple object about ad computer status
SYNTAX
get-adcompterstate
#>

function Get-ADComputerState {
  [cmdletbinding()]
  param (
    [parameter(Mandatory = $false)]
    [pscredential]$Credential
  )

  # Checking credentials
  # Credential is used because i'm managing a server using a mgt console using a local admin account
  # This is accompanied by a $Credential declaration on powershell profile for seemless use
  if (-not $Credential) {
    $Credential = Get-Credential -Message "Enter credentials to access Active Directory"
  }


  # pulling all computer accounts from AD (you need to have the AD module installed and RSAT tools)
  $adComputers = Get-ADComputer -filter * -Credential $Credential | Select-Object -ExpandProperty name 

  # testing connectivity to each computer in parallel and returning a custom object with the status
  $adComputers | ForEach-Object -Parallel {
    $computername = $_

    Try {
      $online = Test-Connection -ComputerName $_ -Count 1 -Quiet -TimeoutSeconds 2 -ErrorAction Stop

      [PSCustomObject]@{
        Name      = $computername
        Status    = if ($online) { "Online" } else { "Offline" }
        LastCheck = Get-Date -Format "HH:mm"
      }
    }
    catch {
      [PSCustomObject]@{
        Name      = $computername
        Status    = "Error: $($_.Exception.Message)"
        LastCheck = Get-Date -Format "HH:mm"
      }
    }

  } -ThrottleLimit 10 
} # function
