---
external help file: PSP-AzureInventory-help.xml
Module Name: PSP-AzureInventory
online version: https://www.powershellpr0mpt.com
schema: 2.0.0
---

# Get-PspAzResourceInfo

## SYNOPSIS
Gets Azure Resource information

## SYNTAX

```
Get-PspAzResourceInfo [<CommonParameters>]
```

## DESCRIPTION
Provides an easy overview of Azure Resource information.
Consolidating information from various sources in to one output, such as ResourceType, if it's an Azure RM or Classic object and more

## EXAMPLES

### EXAMPLE 1
```
Get-PspAzResourceInfo
```

ResourceName                    ResourceGroupName        ResourceType                                 AzureClassic Location
------------                    -----------------        ------------                                 ------------ --------
DefaultWorkspace-WEU            DefaultResourceGroup-WEU Microsoft.OperationalInsights/workspaces     False        westeurope
Security(DefaultWorkspace-WEU)  defaultresourcegroup-weu Microsoft.OperationsManagement/solutions     False        westeurope
NetworkWatcher_westeurope       NetworkWatcherRG         Microsoft.Network/networkWatchers            False        westeurope
PSP-Automation                  PSP-Automation           Microsoft.Automation/automationAccounts      False        westeurope
Alert ServiceDesk               PSP-LogAnalytics         Microsoft.Insights/actiongroups              False        global

Gets all Azure Resource objects for the currently connected subscription and displays the default properties

### EXAMPLE 2
```
Get-PspAzResourceInfo | Format-List
```

ResourceName      : MyVNET
ResourceGroupName : PSP-Networking
ResourceType      : Microsoft.Network/virtualNetworks
AzureClassic      : False
Location          : westeurope
Subscription      : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
ReportDateTime    : 2021-04-19 13-37

Gets all Azure Resource objects for the currently connected subscription and displays the full properties

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSP.Azure.Inventory.Resource
## NOTES
Name: Get-PspAzResourceInfo.ps1
Author: Robert Prüst
Module: PSP-AzureInventory
DateCreated: 12-04-2021
DateModified: 19-04-2021
Blog: https://www.powershellpr0mpt.com

## RELATED LINKS

[https://www.powershellpr0mpt.com](https://www.powershellpr0mpt.com)

