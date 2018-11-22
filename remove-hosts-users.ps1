Import-Module ActiveDirectory
$DNSServer = "dc1.example.com"
$ZoneName = "example.com"
$FileHosts = "hosts.txt"
ForEach ($Computer in (Get-Content $FileHosts))
{
  Try {
    Remove-ADComputer $Computer -ErrorAction Stop
    Add-Content hosts-removed.log -Value "$Computer removed"
  }
  Catch {
    Add-Content hosts-removed.log -Value "$Computer not found because $($Error[0])"
  }
  $NodeDNS = $null
  $NodeDNS = Get-DnsServerResourceRecord -ZoneName $ZoneName -ComputerName $DNSServer -Node $Computer -RRType A -ErrorAction SilentlyContinue
  if($NodeDNS -eq $null){
    Write-Host "No DNS record found"
  } else {
    Remove-DnsServerResourceRecord -ZoneName $ZoneName -ComputerName $DNSServer -InputObject $NodeDNS -Force
  }
}

$FileUsers = "users.txt"
ForEach ($User in (Get-Content $FileUsers))
{
  Remove-ADUser -Identity -Confirm:$False $User
}
