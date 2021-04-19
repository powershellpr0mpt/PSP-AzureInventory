function Get-PspAzPublicIpInfo {
    <#
    .SYNOPSIS
    Gets Azure Public IP Address object information
    
    .DESCRIPTION
    Provides an easy overview of Public IP Address object information.
    Consolidating information from various sources in to one output, such as IpAddress, if it's Orphaned, Allocation method and more
    
    .EXAMPLE
    C:\temp>Get-PspAzPublicIpInfo

    PublicIpName        ResourceGroupName               IpAddress     Orphaned LinkedResourceName  IpAllocationMethod
    ------------        -----------------               ---------     -------- ------------------  ------------------
    vmpspweuprddm03-pip RG-PRD-PSP-APP                  12.34.56.78   False    vmpspweuprddm03-nic Static
    vmpspweuprdim02_pip RG-PRD-PSP-APP                  12.34.56.79   False    vmpspweuprdim02986  Static
    vmpspweuprdpx01-pip RG-PRD-PSP-APP                  12.34.56.80   False    vmpspweuprdpx0187   Static
    utvb3bgdh3ebwIP     RG-PRD-PSP-MERzlbhrdtfyqobi     12.34.56.81   False    vmpspweuprdmer01Nic Dynamic
    vmpspweuprdmg02-pip RG-PRD-PSP-MGM                  12.34.56.82   False    vmpspweuprdmg02-nic Static

    Gets all Public IP Address objects for the currently connected subscription and displays the default properties

    .EXAMPLE
    C:\temp>Get-PspAzPublicIpInfo | Format-List

    PublicIpName         : AG_PSP_PRD_PIP
    ResourceGroupName    : RG-PRD-PSP-NET
    IpAddress            : 12.34.56.78
    Orphaned             : False
    LinkedResourceName   : ag_psp_weu_prd01
    LinkedResourceConfig : appGatewayFrontendIP
    LinkedResourceType   : applicationGateways
    LinkedResourceRG     : RG-PRD-PSP-NET
    IpAllocationMethod   : Dynamic
    DomainNameLabel      :
    FQDN                 : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k.cloudapp.net
    ReverseFQDN          :
    Sku                  : Basic
    TagsAvailable        : False
    Tags                 : env=demo;createdby=ARM
    Location             : westeurope
    Subscription         : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
    ResourceGuid         : 1a2b3c4d-1234-5678-9101-5e6f7g8h9i0k
    ReportDateTime       : 2021-04-19 13-37

    Gets all Public IP Address objects for the currently connected subscription and displays the full properties
    
    .NOTES
    Name: Get-PspAzPublicIpInfo.ps1
    Author: Robert Prüst
    Module: PSP-AzureInventory
    DateCreated: 12-04-2021
    DateModified: 19-04-2021
    Blog: https://www.powershellpr0mpt.com

    .LINK
    https://www.powershellpr0mpt.com
    #>

    [OutputType('PSP.Azure.Inventory.PublicIp')]
    [cmdletbinding()]
    param()

    begin {
        $Date = Get-Date

        try {
            $PublicIps = Get-AzPublicIpAddress -ErrorAction Stop
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
            foreach ($IP in $PublicIps) {
                Clear-Variable Tags, TagsAvailable, Tagpairs, TagString -ErrorAction SilentlyContinue

                $Tags = $IP.Tags
                $TagsAvailable = if ($Tags.Keys.Count -ge 1) { $true } else { $false }
                $TagPairs = if ($TagsAvailable) { $Tags.Keys | ForEach-Object { "{0} `= {1}" -f $_, $Tags[$_] } } else { '' }
                $TagString = $TagPairs -join ';'

                [PSCustomObject]@{
                    PSTypeName           = 'PSP.Azure.Inventory.PublicIp'
                    PublicIpName         = $IP.Name
                    ResourceGroupName    = $IP.ResourceGroupName
                    IpAddress            = $IP.IpAddress
                    Orphaned             = if ($null -eq $IP.IpConfiguration) { $true } else { $false }
                    LinkedResourceName   = if ($null -eq $IP.IpConfiguration) { '' }else { $IP.IpConfiguration.Id.Split('/')[-3] }
                    LinkedResourceConfig = if ($null -eq $IP.IpConfiguration) { '' }else { $IP.IpConfiguration.Id.Split('/')[-1] }
                    LinkedResourceType   = if ($null -eq $IP.IpConfiguration) { '' }else { $IP.IpConfiguration.Id.Split('/')[-4] }
                    LinkedResourceRG     = if ($null -eq $IP.IpConfiguration) { '' }else { $IP.IpConfiguration.Id.Split('/')[4] }
                    IpAllocationMethod   = $IP.PublicIpAllocationMethod
                    DomainNameLabel      = $IP.DnsSettings.DomainNameLabel
                    FQDN                 = $IP.DnsSettings.Fqdn
                    ReverseFQDN          = $IP.DnsSettings.ReverseFqdn
                    Sku                  = $IP.Sku.Name
                    TagsAvailable        = $TagsAvailable
                    Tags                 = $TagString
                    Location             = $IP.Location
                    Subscription         = $IP.Id.split('/')[2]
                    ResourceGuid         = $IP.ResourceGuid
                    ReportDateTime       = ("{0:yyyy}-{0:MM}-{0:dd} {0:HH}-{0:mm}" -f $Date)
                }
            }
        }
        else {
            Write-Warning "Unable to continue"
        }
    }
}