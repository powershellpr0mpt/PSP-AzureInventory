function Get-PspAzSubnetInfo {
    <#
    .SYNOPSIS
    Gets Azure Subnet information
    
    .DESCRIPTION
    Provides an easy overview of Subnet information.
    Consolidating information from various sources in to one output, such as VNet, DNS Server, NSG and more
    
    .EXAMPLE
    C:\temp>Get-PspAzSubnetInfo

    SubnetName         ResourceGroupName VNet    AddressPrefix NsgOnSubnet
    ----------         ----------------- ----    ------------- -----------
    default            PSP-Networking    MyVNET  10.2.0.0/24   False
    Backend            PSP-Networking    VM-VNet 10.1.0.0/24   True
    azurebastionsubnet PSP-Networking    VM-VNet 10.1.1.0/27   False
    
    Gets all Subnets for the currently connected subscription and displays the default properties

    .EXAMPLE
    C:\temp>Get-PspAzSubnetInfo | Format-List

    SubnetName              : Backend
    VNet                    : VM-VNet
    VNetResourceGroup       : PSP-Networking
    VnetDnsServer           : Azure Managed DNS
    AddressPrefix           : 10.1.0.0/24
    NsgOnSubnet             : True
    SubnetNsg               : PSP-NSG_Backend
    SubnetNsgResourceGroup  : PSP-Networking
    RouteTableEnabled       : False
    RouteTableName          :
    RouteTableResourceGroup :
    ServiceEndpoints        :
    PrivateEndpoints        :
    Location                : westeurope
    Subscription            : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
    ResourceGuid            : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
    ReportDateTime          : 2021-04-19 13-37

    Gets all Subnets for the currently connected subscription and displays the full properties

    .NOTES
    Name: Get-PspAzSubnetInfo.ps1
    Author: Robert Prüst
    Module: PSP-AzureInventory
    DateCreated: 12-04-2021
    DateModified: 19-04-2021
    Blog: https://www.powershellpr0mpt.com

    .LINK
    https://www.powershellpr0mpt.com
    #>

    [OutputType('PSP.Azure.Inventory.Subnet')]
    [cmdletbinding()]
    param()

    begin {
        $Date = Get-Date

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