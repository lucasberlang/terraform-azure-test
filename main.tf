
data "vault_azure_access_credentials" "auth" {
  backend                     = var.backend
  role                        = var.role
  validate_creds              = true
  num_sequential_successes    = 30
  num_seconds_between_tests   = 1
  max_cred_validation_seconds = 1200
}

provider "azurerm" {
  features {}

  # More information on the authentication methods supported by
  # the AzureRM Provider can be found here:
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
  subscription_id = var.subscription_id
  client_id       = data.vault_azure_access_credentials.auth.client_id
  client_secret   = data.vault_azure_access_credentials.auth.client_secret
  tenant_id       = var.tenant_id
}

resource "azurerm_resource_group" "example-test" {
  name     = "example-test"
  location = var.region
}