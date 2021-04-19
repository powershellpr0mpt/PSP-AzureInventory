---
external help file: PSP-AzureInventory-help.xml
Module Name: PSP-AzureInventory
online version: https://www.powershellpr0mpt.com
schema: 2.0.0
---

# Get-PspAzPublicIpInfo

## SYNOPSIS
Gets Azure Public IP Address object information

## SYNTAX

```
Get-PspAzPublicIpInfo [<CommonParameters>]
```

## DESCRIPTION
Provides an easy overview of Public IP Address object information.
Consolidating information from various sources in to one output, such as IpAddress, if it's Orphaned, Allocation method and more

## EXAMPLES

### EXAMPLE 1
```
Get-PspAzPublicIpInfo
```

PublicIpName        ResourceGroupName      IpAddress     Orphaned LinkedResourceName  IpAllocationMethod
------------        -----------------      ---------     -------- ------------------  ------------------
vmpspweuprddm03-pip RG-PRD-PSP-APP         12.34.56.78   False    vmpspweuprddm03-nic Static
vmpspweuprdim02_pip RG-PRD-PSP-APP         12.34.56.79   False    vmpspweuprdim02986  Static
vmpspweuprdpx01-pip RG-PRD-PSP-APP         12.34.56.80   False    vmpspweuprdpx0187   Static
utvb3bgdh3ebwIP     RG-PRD-PSP-MER         12.34.56.81   False    vmpspweuprdmer01Nic Dynamic
vmpspweuprdmg02-pip RG-PRD-PSP-MGM         12.34.56.82   False    vmpspweuprdmg02-nic Static

Gets all Public IP Address objects for the currently connected subscription and displays the default properties

### EXAMPLE 2
```
Get-PspAzPublicIpInfo | Format-List
```

PublicIpName         : AG_PSP_PRD_PIP
ResourceGroupName    : RG-PRD-PSP-NET
IpAddress            : 12.34.56.78
Orphaned             : False
LinkedResourceName   : ag_psp_weu_prd01
LinkedResourceConfig : appGatewayFrontendIP
LinkedResourceType   : applicationGateways
LinkedResourceRG     : RG-PRD-PSP-NET
IpAllocationMethod   : Dynamic
DomainNameLabel      :
FQDN                 : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k.cloudapp.net
ReverseFQDN          :
Sku                  : Basic
TagsAvailable        : False
Tags                 : env=demo;createdby=ARM
Location             : westeurope
Subscription         : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
ResourceGuid         : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
ReportDateTime       : 2021-04-19 13-37

Gets all Public IP Address objects for the currently connected subscription and displays the full properties

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSP.Azure.Inventory.PublicIp
## NOTES
Name: Get-PspAzPublicIpInfo.ps1
Author: Robert Prüst
Module: PSP-AzureInventory
DateCreated: 12-04-2021
DateModified: 19-04-2021
Blog: https://www.powershellpr0mpt.com

## RELATED LINKS

[https://www.powershellpr0mpt.com](https://www.powershellpr0mpt.com)

