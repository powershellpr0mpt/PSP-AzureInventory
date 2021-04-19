function Get-PspAzVnetInfo {
    <#
    .SYNOPSIS
    Gets Azure Virtual Network information
    
    .DESCRIPTION
    Provides an easy overview of Virtual Network information.
    Consolidating information from various sources in to one output, such as Subnets, Peering, if it's DDOS protected and more
    
    .EXAMPLE
    C:\temp>Get-PspAzVnetInfo

        VNetName ResourceGroupName AddressSpace Subnets                    VNetDnsServer
    -------- ----------------- ------------ -------                    -------------
    MyVNET   PSP-Networking    10.2.0.0/16  default                    Azure Managed DNS
    VM-VNet  PSP-Networking    10.1.0.0/16  Backend;azurebastionsubnet Azure Managed DNS
    
    Gets all Virtual Networks for the currently connected subscription and displays the default properties

    .EXAMPLE
    C:\temp>Get-PspAzVnetInfo | Format-List

    VnetName          : vnPSPWEUPRD
    ResourceGroupName : RG-PRD-PSP-NET
    AddressSpace      : 10.31.0.0/20
    VnetDnsServer     : 10.31.4.4;10.31.4.5
    DdosProtection    : Basic
    Subnets           : SNWEUPRDAppGateway;GatewaySubnet;Meraki;SNWEUPRDRemoteDesktopServices;SNWEUPRDApplication;SNWEUPRDBackEndDMZ;SNWEUPRDIdentity;SNWEUPRDData;SNWEUPRDFrontEndDMZ
    PeeringEnabled    : True
    Peerings          : vNetPeerToFortigate
    TagsAvailable     : False
    Tags              : env=demo;createdby=ARM
    Location          : westeurope
    Subscription      : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
    ResourceGuid      : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
    ReportDateTime    : 2021-04-19 13-37

    Gets all Virtual Networks for the currently connected subscription and displays the full properties

    .NOTES
    Name: Get-PspAzVnetInfo.ps1
    Author: Robert Prüst
    Module: PSP-AzureInventory
    DateCreated: 12-04-2021
    DateModified: 19-04-2021
    Blog: https://www.powershellpr0mpt.com

    .LINK
    https://www.powershellpr0mpt.com
    #>

    [OutputType('PSP.Azure.Inventory.Vnet')]
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
                Clear-Variable Tags, TagsAvailable, Tagpairs, TagString -ErrorAction SilentlyContinue

                $Tags = $VNet.Tags
                $TagsAvailable = if ($Tags.Keys.Count -ge 1) { $true } else { $false }
                $TagPairs = if ($TagsAvailable) { $Tags.Keys | ForEach-Object { '{0}={1}' -f $_, $Tags[$_] } } else { $false }
                $TagString = if ($TagPairs) { $TagPairs -join ';' } else { '' }

                [PSCustomObject]@{
                    PSTypeName        = 'PSP.Azure.Inventory.Vnet'
                    VnetName          = $VNet.Name
                    ResourceGroupName = $VNet.ResourceGroupName
                    AddressSpace      = $VNet.AddressSpace.AddressPrefixes -join ';'
                    VnetDnsServer     = if ($VNet.DhcpOptions.DnsServers) { $VNet.DhcpOptions.DnsServers -join ';' } else { 'Azure Managed DNS' }
                    DdosProtection    = if ($VNet.DdosProtectionPlan) { 'Standard' } else { 'Basic' }
                    Subnets           = $Vnet.Subnets.Name -join ';'
                    PeeringEnabled    = if ($Vnet.VirtualNetworkPeerings) { $true } else { $false }
                    Peerings          = $VNet.VirtualNetworkPeerings.Name -join ';'
                    TagsAvailable     = $TagsAvailable
                    Tags              = $TagString
                    Location          = $VNet.Location
                    Subscription      = $VNet.Id.split('/')[2]
                    ResourceGuid      = $VNet.ResourceGuid
                    ReportDateTime    = ("{0:yyyy}-{0:MM}-{0:dd} {0:HH}-{0:mm}" -f $Date)
                }
            }
        }
        else {
            Write-Warning "Unable to continue"
        }
    }
}