function Get-PspAzSubnetInfo {
    #requires -Module AZ.Accounts,Az.Network
    [cmdletbinding()]
    param()

    begin {
        $Date = Get-Date #-Format yyyyMMdd-HHmm

        try {
            $VNets = Get-AzVirtualNetwork -ErrorAction Stop
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
            foreach ($VNet in $VNets) {
                Clear-Variable Subnets, Tags, TagsAvailable, Tagpairs, TagString -ErrorAction SilentlyContinue

                $Subnets = $Vnet.Subnets

                foreach ($Subnet in $Subnets) {
                    [PSCustomObject]@{
                        PSTypeName             = 'PSP.Azure.Inventory.Subnet'
                        SubnetName              = $Subnet.Name
                        VNet                    = $VNet.Name
                        VNetResourceGroup       = $Vnet.ResourceGroupName
                        VnetDnsServer           = if ($VNet.DhcpOptions.DnsServers) { $VNet.DhcpOptions.DnsServers -join ';' } else { 'Azure Managed DNS' }
                        AddressPrefix           = $Subnet.AddressPrefix -join ';'
                        NsgOnSubnet             = if ($Subnet.NetworkSecurityGroup) { $true }else { $false }
                        SubnetNsg               = if ($Subnet.NetworkSecurityGroup) { $Subnet.NetworkSecurityGroup.Id.split('/')[-1] }else { '' }
                        SubnetNsgResourceGroup  = if ($Subnet.NetworkSecurityGroup) { $Subnet.NetworkSecurityGroup.Id.split('/')[-5] }else { '' }
                        RouteTableEnabled       = if ($Subnet.RouteTable) { $true }else { $false }
                        RouteTableName          = if ($Subnet.RouteTable) { $Subnet.RouteTable.Id.split('/')[-1] }else { '' }
                        RouteTableResourceGroup = if ($Subnet.RouteTable) { $Subnet.RouteTable.Id.split('/')[-5] }else { '' }
                        ServiceEndpoints        = $Subnet.ServiceEndpoints -join ';'
                        PrivateEndpoints        = $Subnet.PrivateEndpoints -join ';'
                        Location                = $VNet.Location
                        Subscription            = $VNet.Id.split('/')[2]
                        ResourceGuid            = $VNet.ResourceGuid
                        ReportDateTime          = ("{0:yyyy}-{0:MM}-{0:dd} {0:HH}-{0:mm}" -f $Date)
                    }
                }
            }
        }
        else {
            Write-Warning "Unable to continue"
        }
    }
}
