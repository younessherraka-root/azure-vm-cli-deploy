# 🚀 Automated Azure Infrastructure Deployment (IaC)

This project demonstrates **Infrastructure as Code (IaC)** principles by automating the deployment of a complete Linux environment on Microsoft Azure using **Azure CLI** and **Bash scripting**.

## 🗺️ Deployment Roadmap

### 1. Resource Organization 📦
The foundation starts with a **Resource Group**, providing a logical container for all assets in the `switzerlandnorth` region.
```bash
az group create --name TP-Azure-RG --location switzerlandnorth
