provider "azurerm" {
  features {}
  subscription_id = "<MY_SUBSCRIPTION_ID>" 
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-dbx-terraform"
  location = "eastus2"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "adb-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# PUBLIC SUBNET
resource "azurerm_subnet" "public_subnet" {
  name                 = "adb-public-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "databricks-public-delegation"
    service_delegation {
      name    = "Microsoft.Databricks/workspaces"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# PRIVATE SUBNET
resource "azurerm_subnet" "private_subnet" {
  name                 = "adb-private-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "databricks-private-delegation"
    service_delegation {
      name    = "Microsoft.Databricks/workspaces"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# NSG
resource "azurerm_network_security_group" "nsg" {
  name                = "adb-subnet-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# NSG Associations
resource "azurerm_subnet_network_security_group_association" "public_nsg" {
  subnet_id                 = azurerm_subnet.public_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_network_security_group_association" "private_nsg" {
  subnet_id                 = azurerm_subnet.private_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Databricks Workspace
resource "azurerm_databricks_workspace" "adb" {
  name                        = "adb-tf-demo"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  managed_resource_group_name = "adb-tf-demo-managed-rg"
  sku                         = "standard"

  custom_parameters {
    virtual_network_id                                 = azurerm_virtual_network.vnet.id
    public_subnet_name                                 = azurerm_subnet.public_subnet.name
    private_subnet_name                                = azurerm_subnet.private_subnet.name
    public_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.public_nsg.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.private_nsg.id
    no_public_ip                                       = true
  }
}
