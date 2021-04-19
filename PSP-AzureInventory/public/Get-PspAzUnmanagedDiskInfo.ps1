function Get-PspAzUnmanagedDiskInfo {
    <#
    .SYNOPSIS
    Gets Azure Unmanaged Disk (VHD) information
    
    .DESCRIPTION
    Provides an easy overview of Virtual Machines' Unmanaged Disk (VHD) information.
    Consolidating information from various sources in to one output, such as Storage Account, if it's Orphaned, Snapshot information and more
    
    .EXAMPLE
    C:\temp>Get-PspAzUnmanagedDiskInfo

    VhdName                   ResourceGroupName   StorageAccount           DiskSizeGB Orphaned IsSnapshot
    -------                   -----------------   --------------           ---------- -------- ----------
    vmpspweuprdah02-e.vhd     rg-prd-psp-data     salrspspweuprddatadisk01 1023       False    True
    ANSVHR203-disk2.vhd       rg-prd-psp-data     salrspspweuprdosdisk01   75         False    True
    ANSVHR203-disk2.vhd       rg-prd-psp-data     salrspspweuprdosdisk01   75         False    False
    vmpspweuprdah02-c.vhd     rg-prd-psp-data     salrspspweuprdosdisk01   127        False    True

    Gets all Unmanaged Disks (VHD) for the currently connected subscription and displays the default properties

    .EXAMPLE
    C:\temp>Get-PspAzUnmanagedDiskInfo | Format-List

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
    
    .NOTES
    Name: Get-PspAzUnmanagedDiskInfo.ps1
    Author: Robert Prüst
    Module: PSP-AzureInventory
    DateCreated: 12-04-2021
    DateModified: 19-04-2021
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