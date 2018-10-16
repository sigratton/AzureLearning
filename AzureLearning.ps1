$ResourceGroupName = "AzureLearning"
$CustomUser = "CustomUser@simongrattonbankwestcom362.onmicrosoft.com"

Write-Host "Logging In"


Write-Host "Create custom user"
$User = az ad user create --display-name "CustomUser" --user-principal-name $CustomUser --password Rahu7159 | ConvertFrom-Json

Write-Host "Creating group"
$Group = az ad group create --display-name AzureLearningGroupReadOnly --mail-nickname AzureLearningGroup | ConvertFrom-Json

Write-Host "Adding user to group"
az ad group member add --group $Group.displayName --member-id $User.objectId

Write-Host "Create Resource Group"
$ResGroup = az group create -l australiaeast -n $ResourceGroupName | ConvertFrom-Json

Write-Host "Assigning user to read role in resource group"
$Role = az role assignment create --role Reader --assignee $Group.objectId --resource-group $ResGroup.name | ConvertFrom-Json

Write-Host "Creating Virtual Network In Resource Group"
$Vnet = az network vnet create --resource-group $ResGroup.name --name AzLrnVnet --address-prefix 192.168.1.0/28 --subnet-name sub1 --subnet-prefix 192.168.1.0/29 | ConvertFrom-Json

#$GWVnet = az network vnet subnet create --vnet-name $Vnet.newVNet.name 

Write-Host "Creating public ip address"
$PubIp = az network public-ip create --name AzLrnVnetPubIp --resource-group $ResGroup.name | ConvertFrom-Json

Write-Host "Creating VPN Gateway"
$VnetGateway = az network vnet-gateway create --resource-group $ResGroup.name --name AzLrnVnetGtwy --vnet $Vnet.newVNet.name --gateway-type Vpn --sku VpnGw1 --vpn-type RouteBased --public-ip-address $PubIp.publicIp.name --location australiaeast | ConvertFrom-Json


$delete = Read-Host "Delete Resources [y/n]" 
if($delete -eq "y") {
    Write-Host "Deleting vNet"
    az network vnet delete --name $Vnet.newVNet.name --resource-group $ResGroup.name

    Write-Host "Deleting Resource Group"
    az group delete -n $ResourceGroupName -y

    Write-Host "Deleting User"
    az ad user delete --upn-or-object-id $CustomUser

    Write-Host "Deleting AD Group"
    az ad group delete --group $Group.objectId
}