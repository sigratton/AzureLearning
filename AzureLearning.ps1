$ResourceGroupName = "AzureLearning"
$CustomUser = "CustomUser@simongrattonbankwestcom362.onmicrosoft.com"

Write-Host "Logging In"


$CreateRG = Read-Host "Create Resource Group [y/n]" 
if($CreateRG -eq "y") {

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
}

$CreateVNet = Read-Host "Create VNet [y/n]" 
if($CreateVNet -eq "y") {
    Write-Host "Creating Virtual Network In Resource Group"
    $Vnet = az network vnet create --resource-group $ResourceGroupName --name AzLrnVnet --address-prefix 192.168.1.0/28 --subnet-name sub1 --subnet-prefix 192.168.1.0/29 | ConvertFrom-Json

    $GWVnet = az network vnet subnet create --vnet-name $Vnet.newVNet.name 

    Write-Host "Creating public ip address"
    $PubIp = az network public-ip create --name AzLrnVnetPubIp --resource-group $ResourceGroupName | ConvertFrom-Json

    Write-Host "Creating VPN Gateway"
    $VnetGateway = az network vnet-gateway create --resource-group $ResourceGroupName --name AzLrnVnetGtwy --vnet $Vnet.newVNet.name --gateway-type Vpn --sku VpnGw1 --vpn-type RouteBased --public-ip-address $PubIp.publicIp.name --location australiaeast | ConvertFrom-Json
}

$CreateVM = Read-Host "Create VM [y/n]" 
if($CreateVM -eq "y") {
    Write-Host "Creating VM"
    $Vm = az vm create -n MyVM -g $ResourceGroupName --image UbuntuLTS --size Standard_B1s --admin-username s3lkj2343nd --admin-password 343asdf34affa@
}

$CreateBlob = Read-Host "Create Blob Storage [y/n]" 
if($CreateBlob -eq "y") {
    Write-Host "Creating Storage Account"
    $StorageAc = az storage account create --name 9c2a6f3cdf904fa7aedc03dd --resource-group $ResourceGroupName --location australiaeast --kind StorageV2 --sku Standard_LRS | ConvertFrom-Json

    Write-Host "Getting storage account keys"
    $StorageAcKeys = az storage account keys list --account-name $StorageAc.name --resource-group $ResourceGroupName | ConvertFrom-Json

    Write-Host "Creating Blob Storage Container"
    $BlobStore = az storage container create --name alstoragecontainer --account-name $StorageAc.name --account-key $StorageAcKeys[0].value
}

$CreateAppSvPlan = Read-Host "Create App Service Plan [y/n]" 
if($CreateAppSvPlan -eq "y") {
    $AppPlan = az appservice plan create --name $ResourceGroupName --resource-group $ResourceGroupName --location australiaeast | ConvertFrom-Json
}

$CreateDB = Read-Host "Create Cosmos DB [y/n]" 
if($CreateDB -eq "y") {
    $Db = az cosmosdb create --name azurelearning --resource-group $ResourceGroupName | ConvertFrom-Json
}

$delete = Read-Host "Delete Resources [y/n]" 
if($delete -eq "y") {
    Write-Host "Deleting Resource Group"
    az group delete -n $ResourceGroupName -y

    Write-Host "Deleting User"
    az ad user delete --upn-or-object-id $CustomUser

    Write-Host "Deleting AD Group"
    az ad group delete --group $Group.objectId
}