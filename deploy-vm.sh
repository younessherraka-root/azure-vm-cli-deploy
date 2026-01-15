#!/bin/bash
# Azure VM Deployment Script
RG="TP-Azure-RG"
LOC="switzerlandnorth"

az group create --name $RG --location $LOC
az network vnet create -g $RG -n MonVNet --subnet-name MonSubnet
az network nsg create -g $RG -n MonNSG
az network nsg rule create -g $RG --nsg-name MonNSG --name AllowSSH --priority 1000 --destination-port-ranges 22 --access Allow --protocol Tcp
az network nic create -g $RG --name MaCarteReseau --vnet-name MonVNet --subnet MonSubnet --network-security-group MonNSG
az vm create -g $RG --name MaVM-TP --nics MaCarteReseau --image Ubuntu2204 --admin-username azureuser --size Standard_B1s --generate-ssh-keys
