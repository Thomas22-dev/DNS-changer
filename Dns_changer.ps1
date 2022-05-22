Clear-Host

PowerShell.exe -windowstyle hidden {

#---------
#Constants
#---------

#IP
$DnsIpPrimary = "8.8.8.8" #Your preferred DNS
$DnsIpSecondary = "8.8.4.4" #Your auxiliary DNS

#Interface Alias
$InterfaceAlias = "Ethernet" #Your DNS interface to modify 

#---------

#Retrieve the DNS used
$DnsServer = Get-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4
$DnsServerAddress = $DnsServer.Address

#Choose DNS configuration
$NewDnsServerAdressPrimary = [string]
$NewDnsServerAdressSecondary = [string]

If($DnsServerAddress -eq $DnsIpPrimary)
{
 $NewDnsServerAdressPrimary = "Automatic (DHCP)"
 $NewDnsServerAdressSecondary = "" 
}else{
 $NewDnsServerAdressPrimary = $DnsIpPrimary
 $NewDnsServerAdressSecondary = $DnsIpSecondary
}

#Loading the library
Add-Type -AssemblyName Microsoft.VisualBasic

#DNS selection validation input
$Result = [Microsoft.VisualBasic.Interaction]::MsgBox("Your current DNS configuration is: $DnsServerAddress
Configuration to be applied: $NewDnsServerAdressPrimary ; $NewDnsServerAdressSecondary
Click on [no] to change the configuration", 4131,"DNS-changer")

#Information window
function Info-Confirm ($InfoText) {
    [Microsoft.VisualBasic.Interaction]::MsgBox("$InfoText", 4160,"DNS-changer")
}

#Change DNS function
# Param :
# $DnsPrimary and $DnsSecondary => New DNS server addresses
function change-Dns ($DnsPrimary, $DnsSecondary) {
    If($DnsPrimary -eq "Automatic (DHCP)")
    {
        #Reset default configuration
        Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ResetServerAddresses
        $Text = "Modified DNS configuration: " + $DnsPrimary
        $Info = Info-Confirm $Text
    
    }else{
        #Set new DNS
        Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses ($DnsPrimary, $DnsSecondary)
        $Text = "Modified DNS configuration: " + $DnsPrimary + " ; " + $DnsSecondary
        $Info = Info-Confirm $Text
    }
}

#Change DNS
If($Result -eq 6) 
{ 
    #If yes  
    $change = change-Dns $NewDnsServerAdressPrimary, $NewDnsServerAdressSecondary
}elseif ($Result -eq 7) {
    #If no
    #Input new Dns server adress primary and secondary
    $NewDnsServerAdressPrimary = [Microsoft.VisualBasic.Interaction]::InputBox('Enter your preferred DNS','DNS-changer', $DnsIpPrimary)
    $NewDnsServerAdressSecondary = [Microsoft.VisualBasic.Interaction]::InputBox('Enter your auxiliary DNS','DNS-changer', $DnsIpSecondary)
    $change = change-Dns $NewDnsServerAdressPrimary, $NewDnsServerAdressSecondary
    
}else{
    #Cancel
    $Info = Info-Confirm "Modification cancelled"
}


#End 
}