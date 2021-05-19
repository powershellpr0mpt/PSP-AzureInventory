function Get-PspAzBackupVaultInfo {
    <#
    .SYNOPSIS
    Gets Azure Backup information
    
    .DESCRIPTION
    Provides an easy overview of Backup Vault information.
    Consolidating information from various sources in to one output, such as Backup vaults, backup policies, containers and more
    
    .EXAMPLE
    C:\temp>Get-PspAzBackupVaultInfo

    
    Gets all Backup Vault (Recovery Services Vault) Info for the currently connected subscription and displays the default properties

    .EXAMPLE
    C:\temp>Get-PspAzBackupVaultInfo | Format-List


    Gets all Backup Vault (Recovery Services Vault)  Info for the currently connected subscription and displays the full properties

    .NOTES
    Name: Get-PspAzBackupVaultInfo.ps1
    Author: Robert Prüst
    Module: PSP-AzureInventory
    DateCreated: 28-04-2021
    DateModified: 28-04-2021
    Blog: https://www.powershellpr0mpt.com

    .LINK
    https://www.powershellpr0mpt.com
    #>

    [OutputType('PSP.Azure.Inventory.BackupVault')]
    [cmdletbinding()]
    param()

    begin {
        $Date = Get-Date

        try {
            $Vaults = Get-AzRecoveryServicesVault -ErrorAction Stop
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
            foreach ($Vault in $Vaults) {
                $Policies = Get-AzRecoveryServicesBackupProtectionPolicy -VaultId $Vault.ID

                $AzureSQLContainers = Get-AzRecoveryServicesBackupContainer -VaultId $Vault.ID -ContainerType AzureSQL
                $AzureStorageContainers = Get-AzRecoveryServicesBackupContainer -VaultId $Vault.ID -ContainerType AzureStorage
                $AzureVMContainers = Get-AzRecoveryServicesBackupContainer -VaultId $Vault.ID -ContainerType AzureVM
                $AzureVMAppContainers = Get-AzRecoveryServicesBackupContainer -VaultId $Vault.ID -ContainerType AzureVMAppContainer
                $WindowsContainers = Get-AzRecoveryServicesBackupContainer -VaultId $Vault.ID -ContainerType Windows -BackupManagementType MARS

                # if ($AzureSQLContainers){'SQL containers found'}
                # if ($AzureStorageContainers){'Storage containers found'}
                # $BackupItems = if ($AzureVMContainers){
                #     foreach ($VMContainer in $AzureVMContainers){
                #         Get-AzRecoveryServicesBackupItem -Container $VMContainer -VaultId $Vault.ID -WorkloadType AzureVM
                #     }
                # }
                # if ($AzureVMAppContainers){'VM app containers found'}
                # if ($WindowsContainers){'Windows containers found'}

                foreach ($container in $AzureVMContainers) {
                    $LinkedVM = Get-AzVM -Name $container.FriendlyName
                    [PSCustomObject]@{
                        ContainerName  = $container.FriendlyName
                        ResourceGroupName = $container.ResourceGroupName
                        LinkedVm = if ($LinkedVM){$true} else {$false}
                        LinkedVmName = if ($LinkedVM) {$LinkedVM.Name}
                        LinkedVmResourceGroupName = if ($LinkedVM) {$LinkedVM.ResourceGroupName}
                        LinkedVmId = if ($LinkedVM) {$LinkedVM.VmId}
                    }
                }
               



                Clear-Variable Tags, TagsAvailable, Tagpairs, TagString -ErrorAction SilentlyContinue

                [PSCustomObject]@{
                    PSTypeName             = 'PSP.Azure.Inventory.BackupVault'
                    VaultName              = $Vault.Name
                    ResourceGroupName      = $Vault.ResourceGroupName
                    Policies               = $Policies.Name -join ';'
                    WorkloadTypes          = ($Policies.WorkloadType | Sort-Object -Unique) -join ';'
                    BackupManagementTypes  = ($Policies.BackupManagementType | Sort-Object -Unique) -join ';'
                    SqlContainers          = if ($AzureSQLContainers) { $true } else { $false }
                    SqlContainersCount     = if ($AzureSQLContainers) { $AzureSQLContainers.Count } else { $null }
                    StorageContainers      = if ($AzureStorageContainers) { $true } else { $false }
                    StorageContainersCount = if ($AzureStorageContainers) { $AzureStorageContainers.Count } else { $null }
                    VmContainers           = if ($AzureVMContainers) { $true } else { $false }
                    VmContainersCount      = if ($AzureVMContainers) { $AzureVMContainers.Count } else { $null }
                    VmAppContainers        = if ($AzureVMAppContainers) { $true } else { $false }
                    VmAppContainersCount   = if ($AzureVMAppContainers) { $AzureVMAppContainers.Count } else { $null }
                    WindowsContainers        = if ($WindowsContainers) { $true } else { $false }
                    WindowsContainersCount   = if ($WindowssContainers) { $WindowsContainers.Count } else { $null }
                    Location               = $Vault.Location
                    Subscription           = $Vault.SubscriptionId
                    ReportDateTime         = ("{0:yyyy}-{0:MM}-{0:dd} {0:HH}-{0:mm}" -f $Date)
                }
            }
        }
        else {
            Write-Warning "Unable to continue"
        }
    }
}