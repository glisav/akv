provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  # Auth comes from StackGuardian Azure connector
}
