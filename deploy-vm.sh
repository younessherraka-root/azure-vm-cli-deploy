#!/bin/bash

# 1. تعريف المتغيرات (Variables) لسهولة التعديل
RG="TP-Azure-RG"
LOC="switzerlandnorth"
VNET_NAME="MonVNet"
NSG_NAME="MonNSG"
VM_NAME="MaVM-TP"

echo "Starting Deployment in $LOC..."

# 2. إنشاء مجموعة الموارد
az group create --name $RG --location $LOC

# 3. إنشاء الشبكة والشبكة الفرعية
az network vnet create -g $RG -n $VNET_NAME --subnet-name MonSubnet --address-prefix 10.0.0.0/16 --subnet-prefix 10.0.1.0/24

# 4. إنشاء مجموعة الأمان وفتح المنفذ 22 (SSH) والمنفذ 80 (HTTP)
az network nsg create -g $RG -n $NSG_NAME
az network nsg rule create -g $RG --nsg-name $NSG_NAME --name AllowSSH --priority 1000 --destination-port-ranges 22 --access Allow --protocol Tcp
az network nsg rule create -g $RG --nsg-name $NSG_NAME --name AllowHTTP --priority 1001 --destination-port-ranges 80 --access Allow --protocol Tcp

# 5. إنشاء بطاقة الشبكة وربطها بالـ NSG
az network nic create -g $RG --name MaCarteReseau --vnet-name $VNET_NAME --subnet MonSubnet --network-security-group $NSG_NAME

# 6. إنشاء الماكينة مع تثبيت Nginx تلقائياً عند التشغيل
az vm create \
  -g $RG \
  -n $VM_NAME \
  --nics MaCarteReseau \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --size Standard_B1s \
  --custom-data "#cloud-config
package_upgrade: true
packages:
  - nginx
runcmd:
  - systemctl start nginx" \
  --generate-ssh-keys

echo "Deployment Finished! Your VM is ready with Nginx."
