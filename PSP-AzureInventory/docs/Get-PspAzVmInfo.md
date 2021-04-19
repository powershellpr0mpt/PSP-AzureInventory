---
external help file: PSP-AzureInventory-help.xml
Module Name: PSP-AzureInventory
online version: https://www.powershellpr0mpt.com
schema: 2.0.0
---

# Get-PspAzVmInfo

## SYNOPSIS
Gets Azure Virtual Machines information

## SYNTAX

```
Get-PspAzVmInfo [<CommonParameters>]
```

## DESCRIPTION
Provides an easy overview of Virtual Machines information.
Consolidating information from various sources in to one output, such as PowerState, IpAddress, Operating System information and more

## EXAMPLES

### EXAMPLE 1
```
Get-PspAzVmInfo
```

VMName           ResourceGroupName     Size             PowerState             HighlyAvailable PrivateIp
------           -----------------     ----             ----------             --------------- ---------
vmpspweuprdah01  RG-PRD-PSP-APP        Standard_A2m_v2  VM deallocated         True            10.0.1.5
vmpspweuprdah02  RG-PRD-PSP-APP        Standard_A2m_v2  Provisioning succeeded False           10.0.1.6
vmpspweuprdah03  RG-PRD-PSP-APP        Standard_D4s_v3  VM running             True            10.0.1.7

Gets all Virtual Machines for the currently connected subscription and displays the default properties

### EXAMPLE 2
```
Get-PspAzVmInfo | Format-List
```

VMName                       : vmpspweuprdsq03
ResourceGroupName            : RG-PRD-PSP-SQL
Size                         : Standard_L8s
PowerState                   : VM running
HighlyAvailable              : True
AvailabilitySetEnabled       : True
AvailabilitySetName          : ASPSPWEUPRDSQL
AvailabilitySetResourceGroup : RG-PRD-PSP-SQL
ScaleSetEnabled              : False
ScaleSetName                 :
ScaleSetResourceGroup        :
ManagedDisks                 : True
OSStorageType                : Premium_LRS
OSDiskStorageAccount         :
DataDisks                    : 4
NicName                      : vmpspweuprdsq03-nic
NicResourceGroup             : RG-PRD-PSP-SQL
NicDnsServer                 : Azure Managed DNS
NsgOnNic                     : False
NicNsg                       :
NicNsgResourceGroup          :
VNet                         : vnPSPWEUPRD
VnetDnsServer                : 10.31.4.4;10.31.4.5
VNetResourceGroup            : RG-PRD-PSP-NET
Subnet                       : SNWEUPRDData
NsgOnSubnet                  : True
SubnetNsg                    : NSG-Data
SubnetNsgResourceGroup       : RG-PRD-PSP-NET
PublicIpAddress              :
PrivateIPAddress             : 10.31.2.13
PrivateIPAllocationMethod    : Static
BootDiagnostics              : True
BootDiagnosticsStorage       : salrspspweuprdcwfs
HybridBenefit                : False
OperatingSystem              : WindowsServer
OSSku                        : 2016-Datacenter
OSVersion                    : 2016.127.20170406
TagsAvailable                : False
Tags                         : env=demo;createdby=ARM
Location                     : westeurope
Subscription                 : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
VmId                         : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
ReportDateTime               : 2021-04-19 13-37

Gets all Virtual Machines for the currently connected subscription and displays the full properties

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSP.Azure.Inventory.VirtualMachine
## NOTES
Name: Get-PspAzVmInfo.ps1
Author: Robert Prüst
Module: PSP-AzureInventory
DateCreated: 12-04-2021
DateModified: 19-04-2021
Blog: https://www.powershellpr0mpt.com

## RELATED LINKS

[https://www.powershellpr0mpt.com](https://www.powershellpr0mpt.com)

