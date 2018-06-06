#THe purpose of this is to be scheduled whenever a user logs in it is run.  If the Windows
#firewall is off it turns it back on. 

$firewallStatus=(Get-NetFirewallProfile -name private).Enabled


if ($firewallStatus -ne "true")
{
    Set-NetFirewallProfile -Enabled true -PassThru |Out-Null
}

#Get-NetFirewallProfile| select name, enabled |ft -AutoSize