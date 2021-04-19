---
external help file: PSP-AzureInventory-help.xml
Module Name: PSP-AzureInventory
online version: https://www.powershellpr0mpt.com
schema: 2.0.0
---

# Get-PspAzVnetInfo

## SYNOPSIS
Gets Azure Virtual Network information

## SYNTAX

```
Get-PspAzVnetInfo [<CommonParameters>]
```

## DESCRIPTION
Provides an easy overview of Virtual Network information.
Consolidating information from various sources in to one output, such as Subnets, Peering, if it's DDOS protected and more

## EXAMPLES

### EXAMPLE 1
```
Get-PspAzVnetInfo
```

VNetName ResourceGroupName AddressSpace Subnets                    VNetDnsServer
-------- ----------------- ------------ -------                    -------------
MyVNET   PSP-Networking    10.2.0.0/16  default                    Azure Managed DNS
VM-VNet  PSP-Networking    10.1.0.0/16  Backend;azurebastionsubnet Azure Managed DNS

Gets all Virtual Networks for the currently connected subscription and displays the default properties

### EXAMPLE 2
```
Get-PspAzVnetInfo | Format-List
```

VnetName          : vnPSPWEUPRD
ResourceGroupName : RG-PRD-PSP-NET
AddressSpace      : 10.31.0.0/20
VnetDnsServer     : 10.31.4.4;10.31.4.5
DdosProtection    : Basic
Subnets           : SNWEUPRDAppGateway;GatewaySubnet
PeeringEnabled    : True
Peerings          : vNetPeerToFortigate
TagsAvailable     : False
Tags              : env=demo;createdby=ARM
Location          : westeurope
Subscription      : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
ResourceGuid      : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
ReportDateTime    : 2021-04-19 13-37

Gets all Virtual Networks for the currently connected subscription and displays the full properties

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSP.Azure.Inventory.Vnet
## NOTES
Name: Get-PspAzVnetInfo.ps1
Author: Robert Prüst
Module: PSP-AzureInventory
DateCreated: 12-04-2021
DateModified: 19-04-2021
Blog: https://www.powershellpr0mpt.com

## RELATED LINKS

[https://www.powershellpr0mpt.com](https://www.powershellpr0mpt.com)

