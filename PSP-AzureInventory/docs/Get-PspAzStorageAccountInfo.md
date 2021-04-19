---
external help file: PSP-AzureInventory-help.xml
Module Name: PSP-AzureInventory
online version: https://www.powershellpr0mpt.com
schema: 2.0.0
---

# Get-PspAzStorageAccountInfo

## SYNOPSIS
Gets Storage Account information

## SYNTAX

```
Get-PspAzStorageAccountInfo [<CommonParameters>]
```

## DESCRIPTION
Provides an easy overview of Storage Account information.
Consolidating information from various sources in to one output, such as ResourceType, if it's an Azure RM or Classic object and more

## EXAMPLES

### EXAMPLE 1
```
Get-PspAzStorageAccountInfo
```

StorageAccountName    ResourceGroupName      Kind      Replication  EnableHttpsTrafficOnly StaticWebsites
------------------    -----------------      ----      -----------  ---------------------- --------------
pspcloudshell         PSP-CoreInfrastructure StorageV2 Standard_LRS True                   False
pspeventlogstorage001 PSP-LogAnalytics       StorageV2 Standard_LRS True                   False
pspsynology           PSP-CoreInfrastructure StorageV2 Standard_LRS True                   False
pspvmsstorage001      PSP-VMs                StorageV2 Standard_LRS True                   False
pspwebsite            PSP-Website            StorageV2 Standard_LRS True                   True

Gets all Storage Accounts for the currently connected subscription and displays the default properties

### EXAMPLE 2
```
Get-PspAzStorageAccountInfo | Format-List
```

StorageAccountName     : pspwebsite
ResourceGroupName      : PSP-Website
Kind                   : StorageV2
Replication            : Standard_LRS
AccessTier             : Hot
EnableHttpsTrafficOnly : True
EncryptedBlob          : True
EncryptedFile          : True
ContainersUsed         : True
PublicContainers       : False
PublicContainersInfo   :
StaticWebsites         : True
FileSharesUsed         : False
LargeFileShares        : True
TagsAvailable          : False
Tags                   : env=demo;createdby=ARM
Location               : westeurope
Subscription           : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
ReportDateTime         : 2021-04-19 13-37

Gets all Storage Accounts for the currently connected subscription and displays the full properties

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSP.Azure.Inventory.StorageAccount
## NOTES
Name: Get-PspAzStorageAccountInfo.ps1
Author: Robert Prüst
Module: PSP-AzureInventory
DateCreated: 12-04-2021
DateModified: 19-04-2021
Blog: https://www.powershellpr0mpt.com

## RELATED LINKS

[https://www.powershellpr0mpt.com](https://www.powershellpr0mpt.com)

