function Get-PspAzUnmanagedDiskInfo {
    <#
    .SYNOPSIS
    Short description
    
    .DESCRIPTION
    Long description
    
    .EXAMPLE
    An example
    
    .NOTES
    Name: Get-PspAzUnmanagedDiskInfo.ps1
    Author: Robert Prüst
    Module: PSP-AzureInventory
    DateCreated: 12-04-2021
    DateModified: 16-04-2021
    Blog: https://www.powershellpr0mpt.com

    .LINK
    https://www.powershellpr0mpt.com
    #>

    [OutputType('PSP.Azure.Inventory.UnmanagedDisk')]
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
                Clear-Variable StorageKey, Context, Containers, Tags, TagsAvailable, Tagpairs, TagString -ErrorAction SilentlyContinue
                $storageKey = (Get-AzStorageAccountKey -ResourceGroupName $Storage.ResourceGroupName -Name $Storage.StorageAccountName)[0].Value
                $context = New-AzStorageContext -StorageAccountName $Storage.StorageAccountName -StorageAccountKey $storageKey
                $containers = Get-AzStorageContainer -Context $context | Where-Object { $_.Name -notlike 'bootdiagnostics-*' }
                foreach ($container in $containers) {
                    $Vhds = Get-AzStorageBlob -Container $container.Name -Context $context | Where-Object { $_.BlobType -eq 'PageBlob' -AND $_.Name.EndsWith('.vhd') }
                    foreach ($Vhd in $Vhds) {
                        [PSCustomObject]@{
                            PSTypeName        = 'PSP.Azure.Inventory.UnmanagedDisk'
                            VhdName           = $Vhd.Name
                            ResourceGroupName = $Storage.ResourceGroupName
                            StorageAccount    = $Vhd.Context.StorageAccountName
                            LeaseStatus       = $Vhd.ICloudBlob.Properties.LeaseStatus
                            Orphaned          = if ($Vhd.ICloudBlob.Properties.LeaseStatus -eq 'Unlocked') { $true } else { $false }
                            IsSnapshot        = if ($Vhd.SnapshotTime) { $true } else { $false }
                            SnapshotTime      = if ($Vhd.SnapshotTime) { ("{0:yyyy}-{0:MM}-{0:dd} {0:HH}-{0:mm}" -f $Vhd.SnapshotTime.LocalDateTime) } else { '' }
                            DiskSizeGB        = [math]::Round(($Vhd.Length / 1GB), 2)
                            LastModified      = $Vhd.LastModified
                            Created           = $Vhd.ICloudBlob.Properties.Created
                            IsDeleted         = $Vhd.IsDeleted
                            Location          = $Storage.Location
                            Subscription      = $Storage.Id.split('/')[2]
                            ReportDateTime    = ("{0:yyyy}-{0:MM}-{0:dd} {0:HH}-{0:mm}" -f $Date)
                        }
                    }
                }
            }
        }
        else {
            Write-Warning "Unable to continue"
        }
    }
}