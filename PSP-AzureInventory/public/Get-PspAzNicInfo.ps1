function Get-PspAzNicInfo {
    <#
    .SYNOPSIS
    Gets Azure Network Interface information
    
    .DESCRIPTION
    Provides an easy overview of Network Interface information.
    Consolidating information from various sources in to one output, such as LinkedVM, if it's Orphaned, VNet and Subnet information and more
    
    .EXAMPLE
    C:\temp>Get-PspAzNicInfo
    
    NicName             ResourceGroupName               LinkedVM        Orphaned VNet        Subnet
    -------             -----------------               --------         -------- ----        ------
    vmpspweuprdah01-nic RG-PRD-PSP-APP                  vmpspweuprdah01  False    vnPSPWEUPRD SNWEUPRDApplication
    vmpspweuprdah02-nic RG-PRD-PSP-APP                  vmpspweuprdah02  False    vnPSPWEUPRD SNWEUPRDApplication
    vmpspweuprdmg02554  RG-PRD-PSP-APP                                   True     vnPSPWEUPRD SNWEUPRDApplication
    vmpspweuprdmg03624  RG-PRD-PSP-APP                  vmpspweuprdmg03  False    vnPSPWEUPRD SNWEUPRDApplication

    Gets all Network Interfaces for the currently connected subscription and displays the default properties

    .EXAMPLE
    C:\temp>Get-PspAzNicInfo | Format-List

    NicName                   : vmpspweuprdmgm-nic1
    ResourceGroupName         : RG-PRD-PSP-MGM
    LinkedVM                  : vmpspweuprdmgm
    LinkedVMResourceGroup     : rg-weu-prd-psp-mgm
    Orphaned                  : False
    NicDnsServer              : Azure Managed DNS
    NsgOnNic                  : False
    NicNsg                    :
    NicNsgResourceGroup       :
    VNet                      : vnPSPWEUPRD
    VnetDnsServer             : 10.31.4.4;10.31.4.5
    VNetResourceGroup         : RG-PRD-PSP-NET
    Subnet                    : SNWEUPRDFrontEndDMZ
    NsgOnSubnet               : True
    SubnetNsg                 : NSG-FrontEndDMZ
    SubnetNsgResourceGroup    : RG-PRD-PSP-NET
    PublicIpAddress           : 12.34.56.78
    PrivateIPAddress          : 10.31.11.4
    PrivateIPAllocationMethod : Static
    TagsAvailable             : False
    Tags                      : env=demo;createdby=ARM
    Location                  : westeurope
    Subscription              : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
    ResourceGuid              : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
    ReportDateTime            : 2021-04-19 13:37

    Gets all Network Interfaces for the currently connected subscription and displays the full properties

    .NOTES
    Name: Get-PspAzNicInfo.ps1
    Author: Robert Prüst
    Module: PSP-AzureInventory
    DateCreated: 12-04-2021
    DateModified: 19-04-2021
    Blog: https://www.powershellpr0mpt.com

    .LINK
    https://www.powershellpr0mpt.com
    #>

    [OutputType('PSP.Azure.Inventory.Nic')]
    [cmdletbinding()]
    param()

    begin {
        $Date = Get-Date

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
}