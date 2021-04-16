function Get-PspAzVmScaleSetInfo {
    [cmdletbinding()]
    param()

    begin {
        $Date = Get-Date

        try {
            $ScaleSets = Get-AzVmss -ErrorAction Stop
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
            $VMs = foreach ($set in $ScaleSets) { 
                Get-AzVmssVM -ResourceGroupName $set.ResourceGroupName -VMScaleSetName $set.Name -InstanceView 
            }
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
                $TagPairs = if ($TagsAvailable) { $Tags.Keys | ForEach-Object { "{0} `= {1}" -f $_, $Tags[$_] } } else { '' }
                $TagString = $TagPairs -join ';'

                [PSCustomObject]@{
                    PSTypeName                   = 'PSP.Azure.Inventory.VirtualMachine'
                    VMName                       = $VM.Name
                    ResourceGroupName            = $VM.ResourceGroupName
                    Size                         = $VM.Sku.Name
                    PowerState                   = $VM.InstanceView.Statuses.where{ $_.Code -like 'PowerState*' }.Displaystatus
                    HighlyAvailable              = $true
                    AvailabilitySetEnabled       = $false
                    AvailabilitySetName          = ''
                    AvailabilitySetResourceGroup = ''
                    ScaleSetEnabled              = $true
                    ScaleSetName                 = $VM.Id.split('/')[8]
                    ScaleSetResourceGroup        = $VM.Id.split('/')[4]
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
                    HybridBenefit                = if ($Null -eq $VM.LicenseType) { $false }else { $true }
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