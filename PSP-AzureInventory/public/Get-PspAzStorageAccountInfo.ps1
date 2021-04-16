function Get-PspAzStorageAccountInfo {
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