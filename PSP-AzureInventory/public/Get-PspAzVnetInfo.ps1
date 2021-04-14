function Get-PspAzVnetInfo {
    #requires -Module AZ.Accounts,Az.Storage
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
