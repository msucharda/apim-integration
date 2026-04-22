variable "location" {
  type        = string
  description = "Azure region for all resources"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "prefix" {
  type        = string
  description = "Naming prefix for all resources (3-6 chars, lowercase)"
  validation {
    condition     = can(regex("^[a-z]{3,6}$", var.prefix))
    error_message = "Prefix must be 3-6 lowercase letters."
  }
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the virtual network"
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefixes" {
  type        = map(string)
  description = "Map of subnet name to CIDR prefix"
  default = {
    pe   = "10.0.2.0/24"
    apim = "10.0.3.0/24"
  }
}

variable "apim_sku" {
  type        = string
  description = "APIM SKU name"
  default     = "Standardv2"
  validation {
    condition     = contains(["Developer", "Basic", "Standard", "Standardv2", "Premium"], var.apim_sku)
    error_message = "APIM SKU must be one of: Developer, Basic, Standard, Standardv2, Premium."
  }
}

variable "apim_capacity" {
  type        = number
  description = "APIM scale unit count"
  default     = 1
}

variable "apim_publisher_name" {
  type        = string
  description = "Publisher name shown in the APIM developer portal"
}

variable "apim_publisher_email" {
  type        = string
  description = "Publisher notification email address"
}

variable "log_analytics_retention_days" {
  type        = number
  description = "Log Analytics Workspace data retention in days"
  default     = 30
  validation {
    condition     = var.log_analytics_retention_days >= 30 && var.log_analytics_retention_days <= 730
    error_message = "Retention must be between 30 and 730 days."
  }
}

variable "private_dns_zone_apim_id" {
  type        = string
  description = "Resource ID of the existing privatelink.azure-api.net DNS zone (managed by the landing zone)"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to all resources"
  default     = {}
}
