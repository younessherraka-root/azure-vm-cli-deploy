# 🚀 Automated Azure Infrastructure Deployment (IaC)

This project demonstrates **Infrastructure as Code (IaC)** principles by automating the deployment of a complete Linux environment on Microsoft Azure using **Azure CLI** and **Bash scripting**.

## 🗺️ Deployment Roadmap

### 1. Resource Organization 📦
The foundation starts with a **Resource Group**, providing a logical container for all assets in the `switzerlandnorth` region.
```bash
az group create --name TP-Azure-RG --location switzerlandnorth


### Step 2: Virtual Network & Subnet 🌐
Setup an isolated Virtual Network and a dedicated Subnet.
```bash
az network vnet create \
  --resource-group TP-Azure-RG \
  --name MonVNet \
  --address-prefix 10.0.0.0/16 \
  --subnet-name MonSubnet \
  --subnet-prefix 10.0.1.0/24


### Step 3: Network Security Group (NSG) 🛡️
Create a Network Security Group to act as a virtual firewall and open ports for SSH and HTTP traffic.
```bash
# Create the NSG
az network nsg create --resource-group TP-Azure-RG --name MonNSG

# Open Port 22 for SSH management
az network nsg rule create \
  --resource-group TP-Azure-RG \
  --nsg-name MonNSG \
  --name AllowSSH \
  --priority 1000 \
  --destination-port-ranges 22 \
  --access Allow \
  --protocol Tcp

# Open Port 80 for Web traffic (Nginx)
az network nsg rule create \
  --resource-group TP-Azure-RG \
  --nsg-name MonNSG \
  --name AllowHTTP \
  --priority 1001 \
  --destination-port-ranges 80 \
  --access Allow \
  --protocol Tcp


### Step 4: Network Interface (NIC) & Public IP 🔗
Provision a Public IP address and create a Network Interface Card (NIC) to connect the VM to the Virtual Network and the Security Group.
```bash
# Create a Public IP
az network public-ip create \
  --resource-group TP-Azure-RG \
  --name MonPublicIP \
  --sku Standard

# Create the Network Interface (NIC)
az network nic create \
  --resource-group TP-Azure-RG \
  --name MaCarteReseau \
  --vnet-name MonVNet \
  --subnet MonSubnet \
  --network-security-group MonNSG \
  --public-ip-address MonPublicIP

### Step 5: Virtual Machine & Auto-Provisioning 💻
The final step deploys the **Ubuntu 22.04 VM**. We use the `--custom-data` parameter with a `cloud-init` script to automatically upgrade packages and install the **Nginx** web server during the first boot.

```bash
az vm create \
  --resource-group TP-Azure-RG \
  --name MaVM-TP \
  --nics MaCarteReseau \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --size Standard_B1s \
  --generate-ssh-keys \
  --custom-data "#cloud-config
package_upgrade: true
packages:
  - nginx"


