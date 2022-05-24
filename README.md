# DNS-changer

## About the project

This is a PowerShell script that makes changing DNS faster and easier.
It can be used to access sites blocked by your default DNS for example.

## Configuration

1. Open the script with PowerShell ISE and set the constants:

```powershell
#IP
$DnsIpPrimary = "0.0.0.0" #Your preferred DNS
$DnsIpSecondary = "0.0.0.0" #Your auxiliary DNS
$DnsDefault = "192.168.1.1" #Your default DNS

#Interface Alias
$InterfaceAlias = "Interface" #Your DNS interface to modify
```

To find the interface to be modified, run this command in PowerShell:

```powershell
Get-DnsClientServerAddress
```

To find the default ip of your DNS, run this command in PowerShell:

```powershell
Get-DnsClientServerAddress -InterfaceAlias YOUR_INTERFACE -AddressFamily IPv4
```

## Usage

The script detects if your DNS configuration is in automatic mode, if it is the case it will propose you to change your DNS to the server you have defined.
You can return to your automatic configuration by re-running the script.
You also have the possibility to enter a custom DNS.

To run this script you must run it as administrator.

![Untitled](img/Untitled%208.png)

### Creating a shortcut

For a simpler and faster use it is recommended to create a shortcut.

Here is a tutorial:

1. Create a shortcut and paste the following command (including the path to the PowerShell script) :

```powershell
powershell.exe -command "& 'C:\Path_to_the_PowerShell_script'"
```

![Untitled](img/Untitled%203.png)

2. To automatically run the script in administrator mode, go to : Properties, Advanced. Then check : Run as administrator.

![Untitled](img/Untitled%207.png)