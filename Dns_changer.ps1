Clear-Host

PowerShell.exe -windowstyle hidden {

#---------
#Constants
#---------

#IP
$DnsIpPrimary = "8.8.8.8" #Your preferred DNS
$DnsIpSecondary = "8.8.4.4" #Your auxiliary DNS
$DnsDefault = "192.168.1.1" #Your default DNS

#Interface Alias
$InterfaceAlias = "Ethernet" #Your DNS interface to modify 

#---------

#Retrieve the DNS used
$DnsServer = Get-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4
$DnsServerAddress = $DnsServer.Address

#Choose DNS configuration
$NewDnsServerAdressPrimary = [string]
$NewDnsServerAdressSecondary = [string]

If($DnsServerAddress -eq $DnsDefault)
{
 $NewDnsServerAdressPrimary = $DnsIpPrimary
 $NewDnsServerAdressSecondary = $DnsIpSecondary
 $default = $false
}else{
 $NewDnsServerAdressPrimary = $DnsDefault + "(Default)"
 $NewDnsServerAdressSecondary = ""
 $default = $true
}

#Loading the library
Add-Type -AssemblyName Microsoft.VisualBasic

#DNS selection validation input
$Result = [Microsoft.VisualBasic.Interaction]::MsgBox("Your current DNS configuration is: $DnsServerAddress
Configuration to be applied: $NewDnsServerAdressPrimary ; $NewDnsServerAdressSecondary
Click on [no] to change the configuration", 4131,"DNS-changer")

#Information window
function Info-Confirm ([string]$InfoText) {
    [Microsoft.VisualBasic.Interaction]::MsgBox("$InfoText", 4160,"DNS-changer")
}

#Change DNS function
# Param :
# $DnsPrimary and $DnsSecondary => [string]: New DNS server addresses
# $isDefault => [bool] is the default configuration to be applied
function change-Dns ([string]$DnsPrimary, [string]$DnsSecondary, [bool]$isDefault) {
    echo $DnsPrimary
    If($isDefault)
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
    $change = change-Dns $NewDnsServerAdressPrimary $NewDnsServerAdressSecondary $default
}elseif ($Result -eq 7) {
    #If no
    #Input new Dns server adress primary and secondary
    $NewDnsServerAdressPrimary = [Microsoft.VisualBasic.Interaction]::InputBox('Enter your preferred DNS','DNS-changer', $DnsIpPrimary)
    $NewDnsServerAdressSecondary = [Microsoft.VisualBasic.Interaction]::InputBox('Enter your auxiliary DNS','DNS-changer', $DnsIpSecondary)
    $change = change-Dns $NewDnsServerAdressPrimary $NewDnsServerAdressSecondary $false
    
}else{
    #Cancel
    $Info = Info-Confirm "Modification cancelled"
}


#End 
}