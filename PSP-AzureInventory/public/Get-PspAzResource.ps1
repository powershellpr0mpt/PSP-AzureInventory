function Get-PspAzResourceInfo {
    [cmdletbinding()]
    param()

    begin {
        $Date = Get-Date

        try {
            $Resources = Get-AzResource -ErrorAction Stop | Sort-Object ResourceGroupName, ResourceType, Name
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
            foreach ($Resource in $Resources) {

                [PSCustomObject]@{
                    PSTypeName        = 'PSP.Azure.Inventory.Resource'
                    ResourceName      = $Resource.Name
                    ResourceGroupName = $Resource.ResourceGroupName
                    ResourceType      = $Resource.ResourceType
                    AzureClassic      = if ($Resource.ResourceType -eq 'Microsoft.Classic*') { $true } else { $false }
                    Location          = $Resource.Location
                    Subscription      = $Resource.ResourceId.split('/')[2]
                    ReportDateTime    = ("{0:yyyy}-{0:MM}-{0:dd} {0:HH}-{0:mm}" -f $Date)
                }
            }
        }
        else {
            Write-Warning "Unable to continue"
        }
    }
}