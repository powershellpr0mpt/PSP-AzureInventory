function Get-PspAzVmInfo {
    <#
    .SYNOPSIS
    Gets Azure Virtual Machines information
    
    .DESCRIPTION
    Provides an easy overview of Virtual Machines information.
    Consolidating information from various sources in to one output, such as PowerState, IpAddress, Operating System information and more
    
    .EXAMPLE
    C:\temp>Get-PspAzVmInfo

    VMName           ResourceGroupName     Size             PowerState             HighlyAvailable PrivateIp
    ------           -----------------     ----             ----------             --------------- ---------
    vmpspweuprdah01  RG-PRD-PSP-APP        Standard_A2m_v2  VM deallocated         True            10.0.1.5
    vmpspweuprdah02  RG-PRD-PSP-APP        Standard_A2m_v2  Provisioning succeeded False           10.0.1.6
    vmpspweuprdah03  RG-PRD-PSP-APP        Standard_D4s_v3  VM running             True            10.0.1.7

    Gets all Virtual Machines for the currently connected subscription and displays the default properties

    .EXAMPLE
    C:\temp>Get-PspAzVmInfo | Format-List

    VMName                       : vmpspweuprdsq03
    ResourceGroupName            : RG-PRD-PSP-SQL
    Size                         : Standard_L8s
    PowerState                   : VM running
    HighlyAvailable              : True
    AvailabilitySetEnabled       : True
    AvailabilitySetName          : ASPSPWEUPRDSQL
    AvailabilitySetResourceGroup : RG-PRD-PSP-SQL
    ScaleSetEnabled              : False
    ScaleSetName                 :
    ScaleSetResourceGroup        :
    ManagedDisks                 : True
    OSStorageType                : Premium_LRS
    OSDiskStorageAccount         :
    DataDisks                    : 4
    NicName                      : vmpspweuprdsq03-nic
    NicResourceGroup             : RG-PRD-PSP-SQL
    NicDnsServer                 : Azure Managed DNS
    NsgOnNic                     : False
    NicNsg                       :
    NicNsgResourceGroup          :
    VNet                         : vnPSPWEUPRD
    VnetDnsServer                : 10.31.4.4;10.31.4.5
    VNetResourceGroup            : RG-PRD-PSP-NET
    Subnet                       : SNWEUPRDData
    NsgOnSubnet                  : True
    SubnetNsg                    : NSG-Data
    SubnetNsgResourceGroup       : RG-PRD-PSP-NET
    PublicIpAddress              :
    PrivateIPAddress             : 10.31.2.13
    PrivateIPAllocationMethod    : Static
    BootDiagnostics              : True
    BootDiagnosticsStorage       : salrspspweuprdcwfs
    HybridBenefit                : False
    OperatingSystem              : WindowsServer
    OSSku                        : 2016-Datacenter
    OSVersion                    : 2016.127.20170406
    TagsAvailable                : False
    Tags                         : env=demo;createdby=ARM
    Location                     : westeurope
    Subscription                 : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
    VmId                         : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
    ReportDateTime               : 2021-04-19 13-37

    Gets all Virtual Machines for the currently connected subscription and displays the full properties
    
    .NOTES
    Name: Get-PspAzVmInfo.ps1
    Author: Robert Pr??st
    Module: PSP-AzureInventory
    DateCreated: 12-04-2021
    DateModified: 19-04-2021
    Blog: https://www.powershellpr0mpt.com

    .LINK
    https://www.powershellpr0mpt.com
    #>

    [OutputType('PSP.Azure.Inventory.VirtualMachine')]
    [cmdletbinding()]
    param()

    begin {
        $Date = Get-Date

        try {
            $VMs = Get-AzVM -Status -ErrorAction Stop
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
            foreach ($VM in $VMs) {
                Clear-Variable NIC, PublicIPName, PublicIPObject, PublicIPRG, VNet, VNetName, VnetRG, SubnetName, SubnetConfig, Tags, TagsAvailable, Tagpairs, TagString -ErrorAction SilentlyContinue
                $NIC = Get-AzNetworkInterface -ResourceGroupName ($VM.NetworkProfile.NetworkInterfaces.Id.Split('/')[4]) -Name ($VM.NetworkProfile.NetworkInterfaces.Id.Split('/')[-1])

                if ($Nic.IpConfigurations[0].PublicIpAddress.Id) {
                    $PublicIPName = $Nic.IpConfigurations[0].PublicIpAddress.Id.Split('/')[-1]
                    $PublicIPRG = $Nic.IpConfigurations[0].PublicIpAddress.Id.Split('/')[-5]
                }
                if ($PublicIPName) {
                    $PublicIPObject = Get-AzPublicIpAddress -ResourceGroupName $PublicIPRG -Name $PublicIPName
                }
                else {
                    $PublicIPObject = [PSCustomObject]@{IPAddress = '' }
                }
                $VNetName = $NIC.IpConfigurations[0].Subnet.Id.split('/')[-3]
                $VNetRG = $NIC.IpConfigurations[0].Subnet.Id.split('/')[4]
                $SubnetName = $NIC.IpConfigurations[0].Subnet.Id.split('/')[-1]

                $VNet = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $VnetRG
                $SubnetConfig = $Vnet.Subnets.where{ $_.Name -eq $SubnetName }

                $Tags = $VM.Tags
                $TagsAvailable = if ($Tags.Keys.Count -ge 1) { $true } else { $false }
                $TagPairs = if ($TagsAvailable) { $Tags.Keys | ForEach-Object { '{0}={1}' -f $_, $Tags[$_] } } else { $false }
                $TagString = if ($TagPairs) { $TagPairs -join ';' } else { '' }

                [PSCustomObject]@{
                    PSTypeName                   = 'PSP.Azure.Inventory.VirtualMachine'
                    VMName                       = $VM.Name
                    ResourceGroupName            = $VM.ResourceGroupName
                    Size                         = $VM.HardwareProfile.VmSize
                    PowerState                   = $VM.PowerState
                    HighlyAvailable              = if (($null -eq $VM.AvailabilitySetReference) -AND ($null -eq $VM.VirtualMachineScaleSet)) { $false }else { $true }
                    AvailabilitySetEnabled       = if ($VM.AvailabilitySetReference) { $true } else { $false }
                    AvailabilitySetName          = if ($VM.AvailabilitySetReference) { $VM.AvailabilitySetReference.Id.split('/')[-1] } else { '' }
                    AvailabilitySetResourceGroup = if ($VM.AvailabilitySetReference) { $VM.AvailabilitySetReference.Id.split('/')[-5] } else { '' }
                    ScaleSetEnabled              = if ($VM.VirtualMachineScaleSet) { $true } else { $false }
                    ScaleSetName                 = if ($VM.VirtualMachineScaleSet) { $VM.VirtualMachineScaleSet.Id.split('/')[-1] } else { '' }
                    ScaleSetResourceGroup        = if ($VM.VirtualMachineScaleSet) { $VM.VirtualMachineScaleSet.Id.split('/')[-5] } else { '' }
                    ManagedDisks                 = if ($VM.StorageProfile.OsDisk.ManagedDisk) { $true } else { $false }
                    OSStorageType                = if ($VM.StorageProfile.OsDisk.ManagedDisk) { $VM.StorageProfile.OsDisk.ManagedDisk.StorageAccountType }else { 'Unknown' }
                    OSDiskStorageAccount         = if ($null -eq $VM.StorageProfile.OsDisk.ManagedDisk) { $VM.StorageProfile.OsDisk.Vhd.Uri.split('/')[2].split('.')[0] }else { '' }
                    DataDisks                    = if ($null -ne $VM.StorageProfile.DataDisks) { $VM.StorageProfile.DataDisks.Count } else { 0 }
                    NicName                      = $NIC.Name
                    NicResourceGroup             = $NIC.ResourceGroupName
                    NicDnsServer                 = if ($NIC.DnsSettings.DnsServers) { $NIC.DnsSettings.DnsServers -join ';' } else { 'Azure Managed DNS' }
                    NsgOnNic                     = if ($NIC.NetworkSecurityGroup) { $true }else { $false }
                    NicNsg                       = if ($NIC.NetworkSecurityGroup) { $NIC.NetworkSecurityGroup.Id.Split('/')[-1] }else { '' }
                    NicNsgResourceGroup          = if ($NIC.NetworkSecurityGroup) { $NIC.NetworkSecurityGroup.Id.Split('/')[-5] }else { '' }
                    VNet                         = $VNetName
                    VnetDnsServer                = if ($VNet.DhcpOptions.DnsServers) { $VNet.DhcpOptions.DnsServers -join ';' } else { 'Azure Managed DNS' }
                    VNetResourceGroup            = $VnetRG
                    Subnet                       = $SubnetName
                    NsgOnSubnet                  = if ($SubnetConfig.NetworkSecurityGroup) { $true }else { $false }
                    SubnetNsg                    = if ($SubnetConfig.NetworkSecurityGroup) { $SubnetConfig.NetworkSecurityGroup.Id.split('/')[-1] }else { '' }
                    SubnetNsgResourceGroup       = if ($SubnetConfig.NetworkSecurityGroup) { $SubnetConfig.NetworkSecurityGroup.Id.split('/')[-5] }else { '' }
                    PublicIpAddress              = $PublicIPObject.IPAddress
                    PrivateIPAddress             = [string]$Nic.IPConfigurations[0].PrivateIPAddress
                    PrivateIPAllocationMethod    = $Nic.IPconfigurations[0].PrivateIpAllocationMethod
                    BootDiagnostics              = if ($VM.DiagnosticsProfile.BootDiagnostics.Enabled) { $true }else { $false }
                    BootDiagnosticsStorage       = if ($VM.DiagnosticsProfile.BootDiagnostics.Enabled) { if ($VM.DiagnosticsProfile.BootDiagnostics.StorageUri) { $VM.DiagnosticsProfile.BootDiagnostics.StorageUri.split('/')[2].split('.')[0] }else { 'VmManaged' } } else { '' }
                    HybridBenefit                = if ($null -eq $VM.LicenseType) { $false }else { $true }
                    OperatingSystem              = $VM.StorageProfile.ImageReference.Offer
                    OSSku                        = $VM.StorageProfile.ImageReference.Sku
                    OSVersion                    = $VM.StorageProfile.ImageReference.Version
                    TagsAvailable                = $TagsAvailable
                    Tags                         = $TagString
                    Location                     = $VM.Location
                    Subscription                 = $VM.Id.split('/')[2]
                    VmId                         = $VM.VmId
                    ReportDateTime               = ("{0:yyyy}-{0:MM}-{0:dd} {0:HH}-{0:mm}" -f $Date)
                }
            }        
        }
        else {
            Write-Warning "Unable to continue"
        }
    }
}