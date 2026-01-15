#!/bin/bash

# =========================================================================
# Project: Azure Infrastructure as Code (Bash/CLI)
# Description: Automated deployment of VNet, Subnet, NSG, and Ubuntu VM.
# Author: Youness
# =========================================================================

# --- 1. Variables Definition ---
# Defining resource names and location for easy management
RG="TP-Azure-RG"
LOC="switzerlandnorth"
VNET_NAME="MonVNet"
SUBNET_NAME="MonSubnet"
NSG_NAME="MonNSG"
VM_NAME="MaVM-TP"
NIC_NAME="MaCarteReseau"
PUB_IP_NAME="MonPublicIP"

echo "Step 1: Creating Resource Group in $LOC..."
az group create --name $RG --location $LOC

echo "Step 2: Creating Virtual Network and Subnet..."
# Creates a private network with address space 10.0.0.0/16
az network vnet create \
  --resource-group $RG \
  --name $VNET_NAME \
  --address-prefix 10.0.0.0/16 \
  --subnet-name $SUBNET_NAME \
  --subnet-prefix 10.0.1.0/24

echo "Step 3: Creating Public IP Address..."
# Required to access the VM from the internet
az network public-ip create \
  --resource-group $RG \
  --name $PUB_IP_NAME \
  --sku Standard

echo "Step 4: Creating Network Security Group (NSG) and Rules..."
# Firewall configuration
az network nsg create --resource-group $RG --name $NSG_NAME

# Allow SSH (Port 22) for remote management
az network nsg rule create \
  --resource-group $RG \
  --nsg-name $NSG_NAME \
  --name AllowSSH \
  --priority 1000 \
  --destination-port-ranges 22 \
  --access Allow \
  --protocol Tcp

# Allow HTTP (Port 80) for web traffic
az network nsg rule create \
  --resource-group $RG \
  --nsg-name $NSG_NAME \
  --name AllowHTTP \
  --priority 1001 \
  --destination-port-ranges 80 \
  --access Allow \
  --protocol Tcp

echo "Step 5: Creating Network Interface (NIC)..."
# Links the VM to the VNet, Subnet, NSG, and Public IP
az network nic create \
  --resource-group $RG \
  --name $NIC_NAME \
  --vnet-name $VNET_NAME \
  --subnet $SUBNET_NAME \
  --network-security-group $NSG_NAME \
  --public-ip-address $PUB_IP_NAME

echo "Step 6: Deploying Ubuntu Virtual Machine..."
# Provisions the VM and installs Nginx automatically using custom-data
az vm create \
  --resource-group $RG \
  --name $VM_NAME \
  --nics $NIC_NAME \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --size Standard_B1s \
  --generate-ssh-keys \
  --custom-data "#cloud-config
package_upgrade: true
packages:
  - nginx
runcmd:
  - systemctl start nginx"

echo "=========================================================="
echo "Deployment Complete!"
echo "To connect to your VM, use the following IP:"
az network public-ip show -g $RG -n $PUB_IP_NAME --query ipAddress -o tsv
echo "=========================================================="
