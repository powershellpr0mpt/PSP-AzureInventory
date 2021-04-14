function Get-PspAzNicInfo {
    #requires -Module AZ.Accounts,Az.Network
    [cmdletbinding()]
    param()

    begin {
        $Date = Get-Date #-Format yyyyMMdd-HHmm

        try {
            $Nics = Get-AzNetworkInterface -ErrorAction Stop
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
            foreach ($Nic in $Nics) {
                Clear-Variable PublicIPName, PublicIPObject, PublicIPRG, VNet, VNetName, VnetRG, SubnetName, SubnetConfig, Tags, TagsAvailable, Tagpairs, TagString -ErrorAction SilentlyContinue

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
                $VNetName = $Nic.IpConfigurations[0].Subnet.Id.split('/')[-3]
                $VNetRG = $Nic.IpConfigurations[0].Subnet.Id.split('/')[4]
                $SubnetName = $Nic.IpConfigurations[0].Subnet.Id.split('/')[-1]

                $VNet = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $VnetRG
                $SubnetConfig = $Vnet.Subnets.where{ $_.Name -eq $SubnetName }

                $Tags = $Nic.Tags
                $TagsAvailable = if ($Tags.Keys.Count -ge 1) { $true } else { $false }
                $TagPairs = if ($TagsAvailable) { $Tags.Keys | ForEach-Object { "{0} `= {1}" -f $_, $Tags[$_] } } else { '' }
                $TagString = $TagPairs -join ';'

                [PSCustomObject]@{
                    PSTypeName                = 'PSP.Azure.Inventory.Nic'
                    NicName                   = $Nic.Name
                    ResourceGroupName         = $Nic.ResourceGroupName
                    LinkedVM                  = if ($Nic.VirtualMachine) { $Nic.VirtualMachine.id.split('/')[-1] } else { '' }
                    LinkedVMResourceGroup     = if ($Nic.VirtualMachine) { $Nic.VirtualMachine.id.split('/')[-5] } else { '' }
                    Orphaned                  = if ($Nic.VirtualMachine) { $false } else { $true }
                    NicDnsServer              = if ($Nic.DnsSettings.DnsServers) { $NIC.DnsSettings.DnsServers -join ';' } else { 'Azure Managed DNS' }
                    NsgOnNic                  = if ($Nic.NetworkSecurityGroup) { $true }else { $false }
                    NicNsg                    = if ($Nic.NetworkSecurityGroup) { $Nic.NetworkSecurityGroup.Id.Split('/')[-1] }else { '' }
                    NicNsgResourceGroup       = if ($Nic.NetworkSecurityGroup) { $Nic.NetworkSecurityGroup.Id.Split('/')[-5] }else { '' }
                    VNet                      = $VNetName
                    VnetDnsServer             = if ($VNet.DhcpOptions.DnsServers) { $VNet.DhcpOptions.DnsServers -join ';' } else { 'Azure Managed DNS' }
                    VNetResourceGroup         = $VnetRG
                    Subnet                    = $SubnetName
                    NsgOnSubnet               = if ($SubnetConfig.NetworkSecurityGroup) { $true }else { $false }
                    SubnetNsg                 = if ($SubnetConfig.NetworkSecurityGroup) { $SubnetConfig.NetworkSecurityGroup.Id.split('/')[-1] }else { '' }
                    SubnetNsgResourceGroup    = if ($SubnetConfig.NetworkSecurityGroup) { $SubnetConfig.NetworkSecurityGroup.Id.split('/')[-5] }else { '' }
                    PublicIpAddress           = $PublicIPObject.IPAddress
                    PrivateIPAddress          = [string]$Nic.IPConfigurations[0].PrivateIPAddress
                    PrivateIPAllocationMethod = $Nic.IPconfigurations[0].PrivateIpAllocationMethod
                    TagsAvailable             = $TagsAvailable
                    Tags                      = $TagString
                    Location                  = $Nic.Location
                    Subscription              = $Nic.Id.split('/')[2]
                    ResourceGuid              = $Nic.ResourceGuid
                    ReportDateTime            = ("{0:yyyy}-{0:MM}-{0:dd} {0:HH}-{0:mm}" -f $Date)
                }
            }
        } else {
            Write-Warning "Unable to continue"
        }
    }


    # $ReportFile = "{2}\{0}-AzureHealthCheck-{1:yyyy}{1:MM}{1:dd}.xlsx" -f $CustomerName, $Date, $SaveFolder
}
