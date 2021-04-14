function Get-PspAzPeeringInfo {
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
                Clear-Variable RemoteVNetName, RemoteVNetRG, RemotePeer, RemoteGW, Tags, TagsAvailable, Tagpairs, TagString -ErrorAction SilentlyContinue

                $Peerings = $Vnet.VirtualNetworkPeerings

                foreach ($Peering in $Peerings) {
                    $RemoteVNetName = $Peering.RemoteVirtualNetwork.Id.Split('/')[-1]
                    $RemoteVNetRG = $Peering.RemoteVirtualNetwork.Id.Split('/')[-5]

                    $RemotePeer = Get-AzVirtualNetwork -Name $RemoteVNetName -ResourceGroupName $RemoteVNetRG -ErrorAction SilentlyContinue

                    $RemoteGW = if ($Peering.UseRemoteGateways) { Get-AzVirtualNetworkGateway -ResourceGroupName $RemoteVNetRG -ErrorAction SilentlyContinue | Where-Object { ($_.IpConfigurations.Subnet.Id.split('/')[-3]) -eq $RemoteVNetName } | Select-Object -ExpandProperty Name } else { '' }

                    [PSCustomObject]@{
                        PSTypeName                = 'PSP.Azure.Inventory.Peering'
                        PeeringName               = $Peering.Name
                        PeeringState              = $Peering.PeeringState
                        LocalVNet                 = $VNet.Name
                        LocalVNetResourceGroup    = $Vnet.ResourceGroupName
                        RemoteVNet                = $RemoteVNetName
                        RemoteVNetResourceGroup   = $RemoteVNetRG
                        RemoteVNetAddressSpace    = $Peering.RemoteVirtualNetworkAddressSpace.AddressPrefixes -join ';'
                        Orphaned                  = if ($RemotePeer) { $false } else { $true }
                        UseRemoteGateways         = $Peering.UseRemoteGateways
                        RemoteGateways            = $RemoteGW
                        AllowGatewayTransit       = $Peering.AllowGatewayTransit
                        AllowVirtualNetworkAccess = $Peering.AllowVirtualNetworkAccess
                        AllowForwardedTraffic     = $Peering.AllowForwardedTraffic
                        Location                  = $VNet.Location
                        Subscription              = $VNet.Id.split('/')[2]
                        ResourceGuid              = $VNet.ResourceGuid
                        ReportDateTime            = ("{0:yyyy}-{0:MM}-{0:dd} {0:HH}-{0:mm}" -f $Date)
                    }
                }
            }
        }
        else {
            Write-Warning "Unable to continue"
        }
    }
}