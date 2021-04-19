---
external help file: PSP-AzureInventory-help.xml
Module Name: PSP-AzureInventory
online version: https://www.powershellpr0mpt.com
schema: 2.0.0
---

# Get-PspAzUnmanagedDiskInfo

## SYNOPSIS
Gets Azure Unmanaged Disk (VHD) information

## SYNTAX

```
Get-PspAzUnmanagedDiskInfo [<CommonParameters>]
```

## DESCRIPTION
Provides an easy overview of Virtual Machines' Unmanaged Disk (VHD) information.
Consolidating information from various sources in to one output, such as Storage Account, if it's Orphaned, Snapshot information and more

## EXAMPLES

### EXAMPLE 1
```
Get-PspAzUnmanagedDiskInfo
```

VhdName                   ResourceGroupName   StorageAccount           DiskSizeGB Orphaned IsSnapshot
-------                   -----------------   --------------           ---------- -------- ----------
vmpspweuprdah02-e.vhd     rg-prd-psp-data     salrspspweuprddatadisk01 1023       False    True
ANSVHR203-disk2.vhd       rg-prd-psp-data     salrspspweuprdosdisk01   75         False    True
ANSVHR203-disk2.vhd       rg-prd-psp-data     salrspspweuprdosdisk01   75         False    False
vmpspweuprdah02-c.vhd     rg-prd-psp-data     salrspspweuprdosdisk01   127        False    True

Gets all Unmanaged Disks (VHD) for the currently connected subscription and displays the default properties

### EXAMPLE 2
```
Get-PspAzUnmanagedDiskInfo | Format-List
```

VhdName           : vmpspweuprdrhtp-c.vhd
ResourceGroupName : rg-prd-psp-data
StorageAccount    : saplrspspweuprdrds01
LeaseStatus       : Unspecified
Orphaned          : False
IsSnapshot        : True
SnapshotTime      : 2021-04-19 00-57
DiskSizeGB        : 127
LastModified      : 4/18/2021 10:57:46 PM +00:00
Created           : 12/12/2019 9:08:33 AM +00:00
IsDeleted         : False
Location          : westeurope
Subscription      : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
ReportDateTime    : 2021-04-19 13-37

Gets all Unmanaged Disks (VHD) for the currently connected subscription and displays the full properties

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSP.Azure.Inventory.UnmanagedDisk
## NOTES
Name: Get-PspAzUnmanagedDiskInfo.ps1
Author: Robert Prüst
Module: PSP-AzureInventory
DateCreated: 12-04-2021
DateModified: 19-04-2021
Blog: https://www.powershellpr0mpt.com

## RELATED LINKS

[https://www.powershellpr0mpt.com](https://www.powershellpr0mpt.com)

