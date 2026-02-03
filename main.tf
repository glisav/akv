# Ensure the specified Resource Group exists (managed by another team).
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

locals {
  # Sanitize (lowercase + replace common separators with hyphen)
  cust_clean  = lower(replace(replace(replace(replace(replace(var.customer_identifier, " ", "-"), "_", "-"), "/", "-"), ".", "-"), ":", "-"))
  env_clean   = lower(replace(replace(replace(replace(replace(var.environment,        " ", "-"), "_", "-"), "/", "-"), ".", "-"), ":", "-"))
  block_clean = lower(replace(replace(replace(replace(replace(var.building_block,     " ", "-"), "_", "-"), "/", "-"), ".", "-"), ":", "-"))
  topic_clean = lower(replace(replace(replace(replace(replace(var.topic,              " ", "-"), "_", "-"), "/", "-"), ".", "-"), ":", "-"))

  # Optional: collapse a couple of obvious double hyphens that can arise after replacements
  block_norm = replace(replace(local.block_clean,  "---", "-"), "--", "-")
  topic_norm = replace(replace(local.topic_clean, "---", "-"), "--", "-")
  # Full name without suffix: akv-<cust>-<env>-<building_block>-<topic>
  generated_kv_name = "akv-${local.cust_clean}-${local.env_clean}-${local.block_norm}-${local.topic_norm}"

  

}





# Create the Key Vault (legacy access policy model).
resource "azurerm_key_vault" "kv" {
  # ----- Identity & Placement -----
  name                = local.generated_kv_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tenant_id           = var.tenant_id

  # SKU: "standard" or "premium"
  sku_name = lower(var.sku_name)

  tags = {
    customer    = var.customer_identifier
    environment = lower(var.environment)
    region      = lower(var.location)
  }

  # ----- Soft Delete / Purge Protection -----
  purge_protection_enabled   = true
  soft_delete_retention_days = 7

  # ----- Access Policies -----
  dynamic "access_policy" {
    for_each = var.access_policies
    content {
      tenant_id               = var.tenant_id
      object_id               = access_policy.value.object_id
      secret_permissions      = access_policy.value.secret_permissions
      key_permissions         = access_policy.value.key_permissions
      certificate_permissions = try(access_policy.value.certificate_permissions, [])
    }
  }

  lifecycle {

    precondition {
      condition     = length(local.generated_kv_name) >= 3 && length(local.generated_kv_name) <= 24
      error_message = "Key Vault name must be between 3 and 24 characters (got ${length(local.generated_kv_name)})."
    }
    # Extra safety: fail early if no policies are provided.
    precondition {
      condition     = length(var.access_policies) > 0
      error_message = "No access policies specified. At least one is required so someone can access the vault."
    }

    precondition {
      condition     = lower(data.azurerm_resource_group.rg.location) == lower(var.location)
      error_message = "Resource Group and Key Vault locations must match."
    }
  }

}
