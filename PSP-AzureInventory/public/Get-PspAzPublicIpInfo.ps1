function Get-PspAzPublicIpInfo {
    <#
    .SYNOPSIS
    Short description
    
    .DESCRIPTION
    Long description
    
    .EXAMPLE
    An example
    
    .NOTES
    Name: Get-PspAzPublicIpInfo.ps1
    Author: Robert Prüst
    Module: PSP-AzureInventory
    DateCreated: 12-04-2021
    DateModified: 16-04-2021
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