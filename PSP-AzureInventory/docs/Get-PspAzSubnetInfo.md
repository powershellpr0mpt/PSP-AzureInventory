---
external help file: PSP-AzureInventory-help.xml
Module Name: PSP-AzureInventory
online version: https://www.powershellpr0mpt.com
schema: 2.0.0
---

# Get-PspAzSubnetInfo

## SYNOPSIS
Gets Azure Subnet information

## SYNTAX

```
Get-PspAzSubnetInfo [<CommonParameters>]
```

## DESCRIPTION
Provides an easy overview of Subnet information.
Consolidating information from various sources in to one output, such as VNet, DNS Server, NSG and more

## EXAMPLES

### EXAMPLE 1
```
Get-PspAzSubnetInfo
```

SubnetName         ResourceGroupName VNet    AddressPrefix NsgOnSubnet
----------         ----------------- ----    ------------- -----------
default            PSP-Networking    MyVNET  10.2.0.0/24   False
Backend            PSP-Networking    VM-VNet 10.1.0.0/24   True
azurebastionsubnet PSP-Networking    VM-VNet 10.1.1.0/27   False

Gets all Subnets for the currently connected subscription and displays the default properties

### EXAMPLE 2
```
Get-PspAzSubnetInfo | Format-List
```

SubnetName              : Backend
VNet                    : VM-VNet
VNetResourceGroup       : PSP-Networking
VnetDnsServer           : Azure Managed DNS
AddressPrefix           : 10.1.0.0/24
NsgOnSubnet             : True
SubnetNsg               : PSP-NSG_Backend
SubnetNsgResourceGroup  : PSP-Networking
RouteTableEnabled       : False
RouteTableName          :
RouteTableResourceGroup :
ServiceEndpoints        :
PrivateEndpoints        :
Location                : westeurope
Subscription            : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
ResourceGuid            : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
ReportDateTime          : 2021-04-19 13-37

Gets all Subnets for the currently connected subscription and displays the full properties

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSP.Azure.Inventory.Subnet
## NOTES
Name: Get-PspAzSubnetInfo.ps1
Author: Robert Prüst
Module: PSP-AzureInventory
DateCreated: 12-04-2021
DateModified: 19-04-2021
Blog: https://www.powershellpr0mpt.com

## RELATED LINKS

[https://www.powershellpr0mpt.com](https://www.powershellpr0mpt.com)

