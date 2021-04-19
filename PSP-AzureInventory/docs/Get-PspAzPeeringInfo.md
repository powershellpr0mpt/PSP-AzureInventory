---
external help file: PSP-AzureInventory-help.xml
Module Name: PSP-AzureInventory
online version: https://www.powershellpr0mpt.com
schema: 2.0.0
---

# Get-PspAzPeeringInfo

## SYNOPSIS
Gets Azure Virtual Network Peering information

## SYNTAX

```
Get-PspAzPeeringInfo [<CommonParameters>]
```

## DESCRIPTION
Provides an easy overview of Virtual Network Peering information.
Consolidating information from various sources in to one output, such as Local and Remote VNet, if it's Orphaned, Peering state and more

## EXAMPLES

### EXAMPLE 1
```
Get-PspAzPeeringInfo
```

PeeringName         ResourceGroupName  PeeringState LocalVNet   RemoteVNet             Orphaned
-----------         -----------------  ------------ ---------   ----------             --------
vNetPeerToFortigate RG-PRD-PSP-NET      Initiated   vnPSPWEUPRD FortigateProtectedVNet True

Gets all Virtual Network Peering for the currently connected subscription and displays the default properties

### EXAMPLE 2
```
Get-PspAzPeeringInfo | Format-List
```

PeeringName               : vNetPeerToFortigate
PeeringState              : Initiated
LocalVNet                 : vnPSPWEUPRD
LocalVNetResourceGroup    : RG-PRD-PSP-NET
RemoteVNet                : FortigateProtectedVNet
RemoteVNetResourceGroup   : RG-PRD-PSP-VPN
RemoteVNetAddressSpace    : 10.0.0.0/16
Orphaned                  : True
UseRemoteGateways         : False
RemoteGateways            :
AllowGatewayTransit       : False
AllowVirtualNetworkAccess : True
AllowForwardedTraffic     : True
Location                  : westeurope
Subscription              : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
ResourceGuid              : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
ReportDateTime            : 2021-04-19 13-37

Gets all Virtual Network Peering for the currently connected subscription and displays the full properties

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSP.Azure.Inventory.Peering
## NOTES
Name: Get-PspAzPeeringInfo.ps1
Author: Robert Prüst
Module: PSP-AzureInventory
DateCreated: 12-04-2021
DateModified: 16-04-2021
Blog: https://www.powershellpr0mpt.com

## RELATED LINKS

[https://www.powershellpr0mpt.com](https://www.powershellpr0mpt.com)

