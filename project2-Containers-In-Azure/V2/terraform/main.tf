data "azurerm_client_config" "current" {}

terraform {
  required_version = ">= 1.8.0"

  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 4.0"
    }

    random = {
        source = "hashicorp/random"
        version = "~> 3.0"
    }
  }


  backend "azurerm" {
        resource_group_name = "rg-terraform-state"
        storage_account_name = "storageterraformstate967"
        container_name = "state"
        key = "coolkey1234"
  }
}

resource "random_password" "sqladminpassword" {
  length = 16
  special = true
  override_special = "!@#$%&*()-_=+[]{}<>:?"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "blog" {
  name = "rg-azure-containers-001"
  location = "West Europe"

  tags = {
    environment = "lab"
    project = "containers-kubernetes"
  }
}

resource "azurerm_container_registry" "acrcontainerlab07212026001" {
  name = "acrcontainerlab07212026001"
  resource_group_name = azurerm_resource_group.blog.name
  location = azurerm_resource_group.blog.location
  sku = "Basic"

  admin_enabled = false
}

resource "azurerm_kubernetes_cluster" "aks_containerlab_001" {
  name = "aks_containerlab_001"
  resource_group_name = azurerm_resource_group.blog.name
  location = azurerm_resource_group.blog.location

  dns_prefix = "containerlab"

  default_node_pool {
    name = "default"
    node_count = 1
    vm_size = "Standard_D2s_v3" #cheapest available i believe
  }
  
  identity {
    type = "SystemAssigned"
  }

  oidc_issuer_enabled = true
  workload_identity_enabled = true
}

resource "azurerm_role_assignment" "aks_acr" {
  principal_id = azurerm_kubernetes_cluster.aks_containerlab_001.kubelet_identity[0].object_id

  role_definition_name = "AcrPull"

  scope = azurerm_container_registry.acrcontainerlab07212026001.id
}

resource "azurerm_key_vault" "kv_containerlab_001" {
  name = "kvcontainerlab001"
  resource_group_name = azurerm_resource_group.blog.name
  location = azurerm_resource_group.blog.location
  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name = "standard"
}

resource "azurerm_key_vault_secret" "kvsecret_username" {
  name = "kvsecretcontainerlab001"
  value = "mysecretusername"
  key_vault_id = azurerm_key_vault.kv_containerlab_001.id
}

resource "azurerm_key_vault_secret" "kvsecret_password" {
  name = "kvsecretcontainerlab001"
  value = "mysecretvalue"
  key_vault_id = azurerm_key_vault.kv_containerlab_001.id
}

resource "azurerm_user_assigned_identity" "blog" {
  name                = "blog-aks-identity"
  resource_group_name = azurerm_resource_group.blog.name
  location            = azurerm_resource_group.blog.location
}

resource "azurerm_role_assignment" "kv_containerlab_001" {
  principal_id = azurerm_user_assigned_identity.blog.principal_id
  role_definition_name = "Key Vault Secrets User"
  scope = azurerm_key_vault.kv_containerlab_001.id
}

resource "azurerm_mssql_server" "sqlserver_containerlab_001" {
  name = "sqlservercontainerlab001"
  resource_group_name = azurerm_resource_group.blog.name
  location = azurerm_resource_group.blog.location
  version = "12.0"

  administrator_login = "sqladminuser"
  administrator_login_password = random_password.sqladminpassword.result

}

resource "azurerm_mssql_database" "sqldb_containerlab_001" {
  name = "sqldbcontainerlab001"
  server_id = azurerm_mssql_server.sqlserver_containerlab_001.id
}
