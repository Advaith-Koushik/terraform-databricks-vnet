
# Terraform Azure Databricks Deployment (No NAT Gateway)

This repo provisions an Azure Databricks workspace using VNet injection **without** a NAT Gateway to minimize unnecessary costs.

## ✅ What It Does

- Creates an Azure Resource Group
- Deploys a custom Virtual Network and Subnet
- Delegates the subnet to Databricks
- Deploys a Databricks workspace using that subnet
- Avoids auto-provisioned NAT Gateway

## 📦 Files

- `main.tf` - Core infrastructure setup
- `variables.tf` - Configurable variables
- `outputs.tf` - Workspace URL output
- `README.md` - Instructions

## 🧰 Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- Azure account with access rights

## 🛠️ Step-by-Step Usage

1. **Login to Azure**  
```bash
az login
az account set --subscription "<your-subscription-name>"
```

2. **Initialize Terraform**  
```bash
terraform init
```

3. **Review plan**  
```bash
terraform plan
```

4. **Apply the configuration**  
```bash
terraform apply
# Type 'yes' when prompted
```

5. **Launch Workspace**  
Copy the output `databricks_url` and open it in your browser.

6. **Verify**  
Check the managed resource group in Azure Portal. It should have:
- No NAT Gateway
- Your custom VNet and Subnet

## 🧹 Cleanup

```bash
terraform destroy
# Type 'yes' when prompted
```

## 📘 Notes

- You only pay for resources while the cluster is running.
- No NAT = no $32/month base charge!
