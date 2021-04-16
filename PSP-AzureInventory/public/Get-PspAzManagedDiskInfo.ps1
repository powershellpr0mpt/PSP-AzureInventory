function Get-PspAzManagedDiskInfo {
    <#
    .SYNOPSIS
    Gets Azure Virtual Machines' Managed Disk information
    
    .DESCRIPTION
    Provides an easy overview of Virtual Machines' Managed Disk information.
    Consolidating information from various sources in to one output
    
    .EXAMPLE
    An example
    
    .NOTES
    Name: Get-PspAzManagedDiskInfo.ps1
    Author: Robert Prüst
    Module: PSP-AzureInventory
    DateCreated: 12-04-2021
    DateModified: 16-04-2021
    Blog: https://www.powershellpr0mpt.com

    .LINK
    https://www.powershellpr0mpt.com
    #>
    
    [OutputType('PSP.Azure.Inventory.ManagedDisk')]
    [cmdletbinding()]
    param()

    begin {
        $Date = Get-Date

        try {
            $Disks = Get-AzDisk -ErrorAction Stop
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
            foreach ($Disk in $Disks) {
                Clear-Variable Tags, TagsAvailable, Tagpairs, TagString -ErrorAction SilentlyContinue

                $Tags = $Disk.Tags
                $TagsAvailable = if ($Tags.Keys.Count -ge 1) { $true } else { $false }
                $TagPairs = if ($TagsAvailable) { $Tags.Keys | ForEach-Object { "{0} `= {1}" -f $_, $Tags[$_] } } else { '' }
                $TagString = $TagPairs -join ';'

                [PSCustomObject]@{
                    PSTypeName            = 'PSP.Azure.Inventory.ManagedDisk'
                    DiskName              = $Disk.Name
                    ResourceGroupName     = $Disk.ResourceGroupName
                    State                 = $Disk.DiskState
                    DiskSizeGB            = $Disk.DiskSizeGB
                    LinkedVM              = if ($Disk.ManagedBy) { $Disk.ManagedBy.split('/')[-1] } else { '' }
                    LinkedVMResourceGroup = if ($Disk.ManagedBy) { $Disk.ManagedBy.split('/')[-5] } else { '' }
                    Orphaned              = if ($Disk.ManagedBy) { $false } else { $true }
                    CreateOption          = $Disk.CreationData.CreateOption
                    OSDisk                = if ([string]::IsNullOrEmpty($Disk.OsType)) { $false } else { $true }
                    OSFamily              = if ([string]::IsNullOrEmpty($Disk.OsType)) { '' } else { $Disk.OsType.ToString() }
                    OSOffer               = if ($Disk.CreationData.CreateOption -eq 'FromImage') { $Disk.CreationData.ImageReference.Id.split('/')[-5] } else { '' }
                    OSSku                 = if ($Disk.CreationData.CreateOption -eq 'FromImage') { $Disk.CreationData.ImageReference.Id.split('/')[-3] } else { '' }
                    SourceDisk            = if ($Disk.CreationData.CreateOption -eq 'Import') { $Disk.CreationData.SourceUri } else { '' }
                    Encryption            = $Disk.Encryption.Type
                    IopsRW                = $Disk.DiskIOPSReadWrite
                    MpsRW                 = $Disk.DiskMBpsReadWrite
                    HyperVGen             = $Disk.HyperVGeneration
                    TagsAvailable         = $TagsAvailable
                    Tags                  = $TagString
                    Location              = $Disk.Location
                    Subscription          = $Disk.Id.split('/')[2]
                    ResourceGuid          = $Disk.UniqueId
                    ReportDateTime        = ("{0:yyyy}-{0:MM}-{0:dd} {0:HH}-{0:mm}" -f $Date)
                }
            }
        }
        else {
            Write-Warning "Unable to continue"
        }
    }
}