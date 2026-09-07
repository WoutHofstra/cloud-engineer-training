terraform {
  required_version = ">= 1.8.0"

  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 4.0"
    }
  }

  backend "azurerm" {
        resource_group_name = "rg-terraform-state"
        storage_account_name = "storageterraformstate967"
        container_name = "state"
        key = "coolkey1234"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name = "rg-azure-containers-001"
  location = "West Europe"

  tags = {
    environment = "lab"
    project = "containers-kubernetes"
  }
}

resource "azurerm_container_registry" "acrcontainerlab07212026001" {
  name = "acrcontainerlab07212026001"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  sku = "Basic"

  admin_enabled = false
}

resource "azurerm_kubernetes_cluster" "aks_containerlab_001" {
  name = "aks_containerlab_001"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location

  dns_prefix = "containerlab"

  default_node_pool {
    name = "default"
    node_count = 1
    vm_size = "Standard_D2s_v3" #cheapest available i believe
  }
  
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "aks_acr" {
  principal_id = azurerm_kubernetes_cluster.aks_containerlab_001.kubelet_identity[0].object_id

  role_definition_name = "AcrPull"

  scope = azurerm_container_registry.acrcontainerlab07212026001.id
}

