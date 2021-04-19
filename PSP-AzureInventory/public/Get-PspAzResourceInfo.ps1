function Get-PspAzResourceInfo {
    <#
    .SYNOPSIS
    Gets Azure Resource information
    
    .DESCRIPTION
    Provides an easy overview of Azure Resource information.
    Consolidating information from various sources in to one output, such as ResourceType, if it's an Azure RM or Classic object and more
    
    .EXAMPLE
    C:\temp>Get-PspAzResourceInfo

    ResourceName                                                                           ResourceGroupName        ResourceType                                           AzureClassic Location
    ------------                                                                           -----------------        ------------                                           ------------ --------
    DefaultWorkspace-1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k-WEU                              DefaultResourceGroup-WEU Microsoft.OperationalInsights/workspaces               False        westeurope
    Security(DefaultWorkspace-1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k-WEU)                    defaultresourcegroup-weu Microsoft.OperationsManagement/solutions               False        westeurope
    NetworkWatcher_westeurope                                                              NetworkWatcherRG         Microsoft.Network/networkWatchers                      False        westeurope
    PSP-Automation                                                                         PSP-Automation           Microsoft.Automation/automationAccounts                False        westeurope
    Alert ServiceDesk                                                                      PSP-LogAnalytics         Microsoft.Insights/actiongroups                        False        global

    Gets all Azure Resource objects for the currently connected subscription and displays the default properties

    .EXAMPLE
    C:\temp>Get-PspAzResourceInfo | Format-List

    ResourceName      : MyVNET
    ResourceGroupName : PSP-Networking
    ResourceType      : Microsoft.Network/virtualNetworks
    AzureClassic      : False
    Location          : westeurope
    Subscription      : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
    ReportDateTime    : 2021-04-19 13-37

    Gets all Azure Resource objects for the currently connected subscription and displays the full properties

    
    .NOTES
    Name: Get-PspAzResourceInfo.ps1
    Author: Robert Prüst
    Module: PSP-AzureInventory
    DateCreated: 12-04-2021
    DateModified: 16-04-2021
    Blog: https://www.powershellpr0mpt.com

    .LINK
    https://www.powershellpr0mpt.com
    #>

    [OutputType('PSP.Azure.Inventory.Resource')]
    [cmdletbinding()]
    param()

    begin {
        $Date = Get-Date

        try {
            $Resources = Get-AzResource -ErrorAction Stop | Sort-Object ResourceGroupName, ResourceType, Name
            $connection = $true
        }
        catch [System.Management.Automation.CommandNotFoundException] {
            Write-Warning "Azure PowerShell module not found.`nPlease install this by using`n`n`Install-Module -Name AZ"
            $connection = $false
        }
        catch [Microsoft.Azure.Commands.Common.Exceptions.AzPSApplicationException] {
            Write-Warning "Azure PowerShell module not connected.`nPlease run Connect-AzAccount first."
            $connection = $false
        }
        catch [Microsoft.Azure.Commands.Network.Common.NetworkCloudException] {
            Write-Warning "The current subscription type is not permitted to perform operations on any provide namespaces.`nPlease use a different subscription.`nTry Get-AzSubscription and pipe the desired subscription to Set-AzContext"
            $connection = $false 
        }
    }
    process {
        if ($connection) {
            foreach ($Resource in $Resources) {

                [PSCustomObject]@{
                    PSTypeName        = 'PSP.Azure.Inventory.Resource'
                    ResourceName      = $Resource.Name
                    ResourceGroupName = $Resource.ResourceGroupName
                    ResourceType      = $Resource.ResourceType
                    AzureClassic      = if ($Resource.ResourceType -eq 'Microsoft.Classic*') { $true } else { $false }
                    Location          = $Resource.Location
                    Subscription      = $Resource.ResourceId.split('/')[2]
                    ReportDateTime    = ("{0:yyyy}-{0:MM}-{0:dd} {0:HH}-{0:mm}" -f $Date)
                }
            }
        }
        else {
            Write-Warning "Unable to continue"
        }
    }
}