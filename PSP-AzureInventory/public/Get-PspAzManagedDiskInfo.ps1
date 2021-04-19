function Get-PspAzManagedDiskInfo {
    <#
    .SYNOPSIS
    Gets Azure Virtual Machines' Managed Disk information
    
    .DESCRIPTION
    Provides an easy overview of Virtual Machines' Managed Disk information.
    Consolidating information from various sources in to one output, such as LinkedVM, if it's Orphaned, Operating System information and more
    
    .EXAMPLE
    C:\temp>Get-PspAzManagedDiskInfo

    DiskName                  ResourceGroupName       State          LinkedVM         DiskSizeGB Orphaned
    --------                  -----------------       -----          --------         ---------- --------
    fs03_Cloned_E_L           RG-PRD-PSP-APP          Attached       vmPSPweuprdfs03  4096       False
    vmpspweuprdah03-c         RG-PRD-PSP-APP          Attached       vmPSPweuprdah03  127        False
    vmpspweuprdah03-e         RG-PRD-PSP-APP          Attached       vmPSPweuprdah03  512        False
    vmpspweuprddp01-c         RG-PRD-PSP-APP          Attached       vmPSPweuprddp01  127        False
    vmpspweuprddp01-e         RG-PRD-PSP-APP          Attached       vmPSPweuprddp01  64         False
    vmpspweuprdep01_e         RG-PRD-PSP-APP          Attached       vmPSPweuprdep01  128        False
    goldimage_disk1           RG-PRD-PSP-RDS          Reserved       goldimage        128        False
    vmpspimage01_disk1        RG-PRD-PSP-RDS          Unattached                      128        True

    Gets all Managed VM disks for the currently connected subscription and displays the default properties

    .EXAMPLE
    C:\temp>Get-PspAzManagedDiskInfo | Format-List

    DiskName              : vmpspweuprdmg03_OsDisk_1
    ResourceGroupName     : RG-PRD-PSP-APP
    State                 : Attached
    DiskSizeGB            : 127
    LinkedVM              : vmpspweuprdmg03
    LinkedVMResourceGroup : RG-PRD-PSP-APP
    Orphaned              : False
    CreateOption          : FromImage
    OSDisk                : True
    OSFamily              : Windows
    OSOffer               : WindowsServer
    OSSku                 : 2019-Datacenter
    SourceDisk            :
    Encryption            : EncryptionAtRestWithPlatformKey
    IopsRW                : 500
    MpsRW                 : 100
    HyperVGen             : V1
    TagsAvailable         : False
    Tags                  : env=demo;createdby=ARM
    Location              : westeurope
    Subscription          : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
    ResourceGuid          : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
    ReportDateTime        : 2021-04-19 13-37

    Gets all Managed VM disks for the currently connected subscription and displays the full properties
    
    .NOTES
    Name: Get-PspAzManagedDiskInfo.ps1
    Author: Robert Prüst
    Module: PSP-AzureInventory
    DateCreated: 12-04-2021
    DateModified: 19-04-2021
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