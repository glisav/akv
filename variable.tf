variable "tenant_id" {
  description = "Azure AD Tenant (Directory) ID that owns the Key Vault."
  type        = string
}

variable "subscription_id" {
  description = "Target Azure Subscription ID where the Key Vault will be deployed."
  type        = string
}

variable "customer_identifier" {
  description = "Customer short code or identifier."
  type        = string
  validation {
    condition     = length(trimspace(var.customer_identifier)) > 0
    error_message = "customer_identifier cannot be empty."
  }
}

variable "resource_group_name" {
  description = "Name of the EXISTING Resource Group where the Key Vault will be created."
  type        = string
}

variable "environment" {
  description = "Environment label"
  type        = string
}

variable "building_block" {
  description = "Building block name (e.g. network, data, compute)"
  type        = string
  default     = ""
}

variable "topic" {
  description = "Topic name for the resource group (e.g. monitoring, ai, db)"
  type        = string
  default     = ""
}


# variable "key_vault_name" {
#   description = "Globally unique Key Vault name (forms the DNS endpoint)."
#   type        = string
#   default = ""
# }

variable "sku_name" {
  description = "Key Vault SKU: 'standard' or 'premium' (premium is required for HSM-backed keys)."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], lower(var.sku_name))
    error_message = "sku_name must be 'standard' or 'premium'."
  }
}


variable "location" {
  description = "Azure region for the Key Vault. Default is westeurope; if changed, only northeurope is allowed."
  type        = string
  default     = "westeurope"
  validation {
    # Allowed values are exactly 'westeurope' or 'northeurope'
    condition     = contains(["westeurope", "northeurope"], lower(var.location))
    error_message = "Only 'westeurope' or 'northeurope' are allowed for location."
  }
}



variable "access_policies" {
  description = <<EOT
List of Key Vault access policies to configure (legacy model).
Each item:
{
  object_id               = "<GUID of user/app/managed identity>"
  secret_permissions      = ["Get","List","Set", ...]
  key_permissions         = ["Create","Get","Decrypt", ...]
  certificate_permissions = ["Get","List","Create", ...]  // optional
}
EOT
  type = list(object({
    object_id               = string
    secret_permissions      = list(string)
    key_permissions         = list(string)
    certificate_permissions = optional(list(string), [])
  }))
  default = []
}
