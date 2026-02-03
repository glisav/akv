output "key_vault_id" {
  description = "Azure resource ID of the created Key Vault."
  value       = azurerm_key_vault.kv.id
}

output "key_vault_name" {
  description = "Name of the created Key Vault."
  value       = azurerm_key_vault.kv.name
}

output "key_vault_uri" {
  description = "Vault URI (DNS endpoint) used by clients to access secrets/keys."
  value       = azurerm_key_vault.kv.vault_uri
}

output "key_vault_rg" {
  description = "Resource Group name where the Key Vault resides."
  value       = azurerm_key_vault.kv.resource_group_name
}

output "authorization_model" {
  description = "Authorization model in use for this vault."
  value       = "access_policies"
}
