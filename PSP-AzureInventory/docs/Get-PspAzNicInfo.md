---
external help file: PSP-AzureInventory-help.xml
Module Name: PSP-AzureInventory
online version: https://www.powershellpr0mpt.com
schema: 2.0.0
---

# Get-PspAzNicInfo

## SYNOPSIS
Gets Azure Network Interface information

## SYNTAX

```
Get-PspAzNicInfo [<CommonParameters>]
```

## DESCRIPTION
Provides an easy overview of Network Interface information.
Consolidating information from various sources in to one output, such as LinkedVM, if it's Orphaned, VNet and Subnet information and more

## EXAMPLES

### EXAMPLE 1
```
Get-PspAzNicInfo
```

NicName             ResourceGroupName               LinkedVM        Orphaned VNet        Subnet
-------             -----------------               --------         -------- ----        ------
vmpspweuprdah01-nic RG-PRD-PSP-APP                  vmpspweuprdah01  False    vnPSPWEUPRD SNWEUPRDApplication
vmpspweuprdah02-nic RG-PRD-PSP-APP                  vmpspweuprdah02  False    vnPSPWEUPRD SNWEUPRDApplication
vmpspweuprdmg02554  RG-PRD-PSP-APP                                   True     vnPSPWEUPRD SNWEUPRDApplication
vmpspweuprdmg03624  RG-PRD-PSP-APP                  vmpspweuprdmg03  False    vnPSPWEUPRD SNWEUPRDApplication

Gets all Network Interfaces for the currently connected subscription and displays the default properties

### EXAMPLE 2
```
Get-PspAzNicInfo | Format-List
```

NicName                   : vmpspweuprdmgm-nic1
ResourceGroupName         : RG-PRD-PSP-MGM
LinkedVM                  : vmpspweuprdmgm
LinkedVMResourceGroup     : rg-weu-prd-psp-mgm
Orphaned                  : False
NicDnsServer              : Azure Managed DNS
NsgOnNic                  : False
NicNsg                    :
NicNsgResourceGroup       :
VNet                      : vnPSPWEUPRD
VnetDnsServer             : 10.31.4.4;10.31.4.5
VNetResourceGroup         : RG-PRD-PSP-NET
Subnet                    : SNWEUPRDFrontEndDMZ
NsgOnSubnet               : True
SubnetNsg                 : NSG-FrontEndDMZ
SubnetNsgResourceGroup    : RG-PRD-PSP-NET
PublicIpAddress           : 12.34.56.78
PrivateIPAddress          : 10.31.11.4
PrivateIPAllocationMethod : Static
TagsAvailable             : False
Tags                      : env=demo;createdby=ARM
Location                  : westeurope
Subscription              : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
ResourceGuid              : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
ReportDateTime            : 2021-04-19 13:37

Gets all Network Interfaces for the currently connected subscription and displays the full properties

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSP.Azure.Inventory.Nic
## NOTES
Name: Get-PspAzNicInfo.ps1
Author: Robert Prüst
Module: PSP-AzureInventory
DateCreated: 12-04-2021
DateModified: 19-04-2021
Blog: https://www.powershellpr0mpt.com

## RELATED LINKS

[https://www.powershellpr0mpt.com](https://www.powershellpr0mpt.com)

