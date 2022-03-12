Clear-Host

PowerShell.exe -windowstyle hidden {

#---------
#Constants
#---------

#IP
$DnsDefaultIp = "192.168.1.1" #The default DNS you use (automatic configuration)
$DnsIpPrimary = "1.1.1.1" #Your preferred DNS
$DnsIpSecondary = "1.0.0.1" #Your auxiliary DNS

#Interface Alias
$InterfaceAlias = "Ethernet" #Your DNS interface to modify 

#---------

#Retrieve the DNS used
$DnsServer = Get-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4
$DnsServerAddress = $DnsServer.Address

#Choose DNS configuration
$NewDnsServerAdressPrimary = [string]
$NewDnsServerAdressSecondary = [string]

If($DnsServerAddress -eq $DnsDefaultIp)
{
 $NewDnsServerAdressPrimary = $DnsIpPrimary
 $NewDnsServerAdressSecondary = $DnsIpSecondary 
}else{
 $NewDnsServerAdressPrimary = "Automatic (DHCP)"
 $NewDnsServerAdressSecondary = ""
}

#Loading the library
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

#DNS selection validation input
$Result = [System.Windows.Forms.MessageBox]::Show("Your current DNS configuration is: $DnsServerAddress
Configuration to be applied: $NewDnsServerAdressPrimary ; $NewDnsServerAdressSecondary", "DNS-changer" , 4, 32)

#Information window
function Info-Confirm ($InfoText) {
    [System.Windows.Forms.MessageBox]::Show("$InfoText", "DNS-changer" , 0, 64)
}

#Change DNS
If($Result -eq "Yes") 
{ 
  If($NewDnsServerAdressPrimary -eq "Automatic (DHCP)")
  {
    #Reset default configuration
    Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ResetServerAddresses
    $Text = "Modified DNS configuration: " + $NewDnsServerAdressPrimary
    $Info = Info-Confirm $Text
    
  }else{
    #Set new DNS
    Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses ($NewDnsServerAdressPrimary, $NewDnsServerAdressSecondary)
    $Text = "Modified DNS configuration: " + $NewDnsServerAdressPrimary + " ; " + $NewDnsServerAdressSecondary
    $Info = Info-Confirm $Text
  }
}else{
  #Cancel
  $Info = Info-Confirm "Modification cancelled"
}

}