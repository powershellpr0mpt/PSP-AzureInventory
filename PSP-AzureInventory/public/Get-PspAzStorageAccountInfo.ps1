function Get-PspAzStorageAccountInfo {
    <#
    .SYNOPSIS
    Gets Storage Account information
    
    .DESCRIPTION
    Provides an easy overview of Storage Account information.
    Consolidating information from various sources in to one output, such as ResourceType, if it's an Azure RM or Classic object and more
    
    .EXAMPLE
    C:\temp>Get-PspAzStorageAccountInfo

    StorageAccountName    ResourceGroupName      Kind      Replication  EnableHttpsTrafficOnly StaticWebsites
    ------------------    -----------------      ----      -----------  ---------------------- --------------
    pspcloudshell         PSP-CoreInfrastructure StorageV2 Standard_LRS True                   False
    pspeventlogstorage001 PSP-LogAnalytics       StorageV2 Standard_LRS True                   False
    pspsynology           PSP-CoreInfrastructure StorageV2 Standard_LRS True                   False
    pspvmsstorage001      PSP-VMs                StorageV2 Standard_LRS True                   False
    pspwebsite            PSP-Website            StorageV2 Standard_LRS True                   True

    Gets all Storage Accounts for the currently connected subscription and displays the default properties

    .EXAMPLE
    C:\temp>Get-PspAzStorageAccountInfo | Format-List

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
    
    .NOTES
    Name: Get-PspAzStorageAccountInfo.ps1
    Author: Robert Prüst
    Module: PSP-AzureInventory
    DateCreated: 12-04-2021
    DateModified: 19-04-2021
    Blog: https://www.powershellpr0mpt.com

    .LINK
    https://www.powershellpr0mpt.com
    #>

    [OutputType('PSP.Azure.Inventory.StorageAccount')]
    [cmdletbinding()]
    param()

    begin {
        $Date = Get-Date

        try {
            $Storages = Get-AzStorageAccount -ErrorAction Stop
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
            foreach ($Storage in $Storages) {
                Clear-Variable Containers, PublicContainers, StaticWebsites, Tags, TagsAvailable, Tagpairs, TagString -ErrorAction SilentlyContinue

                $Containers = $Storage | Get-AzStorageContainer -ErrorAction SilentlyContinue
                if ($Containers) {
                    $PublicContainers = $Containers.where{ $_.PublicAccess -eq 'Container' }
                }
                if ($Containers) {
                    $StaticWebsites = $Containers.where{ $_.Name -eq '$web' }
                }

                $FileShares = $Storage | Get-AzStorageShare -ErrorAction SilentlyContinue

                $Tags = $Storage.Tags
                $TagsAvailable = if ($Tags.Keys.Count -ge 1) { $true } else { $false }
                $TagPairs = if ($TagsAvailable) { $Tags.Keys | ForEach-Object { "{0} `= {1}" -f $_, $Tags[$_] } } else { '' }
                $TagString = $TagPairs -join ';'

                [PSCustomObject]@{
                    PSTypeName             = 'PSP.Azure.Inventory.StorageAccount'
                    StorageAccountName     = $Storage.StorageAccountName
                    ResourceGroupName      = $Storage.ResourceGroupName
                    Kind                   = $Storage.Kind
                    Replication            = $Storage.Sku.Name
                    AccessTier             = $Storage.AccessTier
                    EnableHttpsTrafficOnly = $Storage.EnableHttpsTrafficOnly
                    EncryptedBlob          = if ($storage.Encryption.Services.Blob.Enabled) { $true } else { $false }
                    EncryptedFile          = if ($storage.Encryption.Services.File.Enabled) { $true } else { $false }
                    ContainersUsed         = if ($Containers) { $true } else { $false }
                    PublicContainers       = if ($PublicContainers) { $true } else { $false }
                    PublicContainersInfo   = if ($PublicContainers) { $PublicContainers.CloudBlobContainer.Uri.AbsoluteUri -join ';' } else { '' }
                    StaticWebsites         = if ($StaticWebsites) { $true } else { $false }
                    FileSharesUsed         = if ($FileShares) { $true } else { $false }
                    LargeFileShares        = if ($Storage.LargeFileSharesState) { $true } else { $false }
                    TagsAvailable          = $TagsAvailable
                    Tags                   = $TagString
                    Location               = $Storage.Location
                    Subscription           = $Storage.Id.split('/')[2]
                    ReportDateTime         = ("{0:yyyy}-{0:MM}-{0:dd} {0:HH}-{0:mm}" -f $Date)
                }
            }
        }
        else {
            Write-Warning "Unable to continue"
        }
    }
}