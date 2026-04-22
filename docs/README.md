# THMP APIM Infrastructure

> Terraform-managed Azure API Management (Standard v2) with VNet integration and private endpoint.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│  Resource Group: rg-thmp-prod-sc  (Sweden Central)          │
│                                                             │
│  ┌──────────────────────────────────────────────────┐       │
│  │  VNet: vnet-thmp-prod-sc  (10.0.0.0/16)         │       │
│  │                                                  │       │
│  │  ┌───────────────────┐  ┌──────────────────────┐ │       │
│  │  │ snet-pe           │  │ snet-apim            │ │       │
│  │  │ 10.0.2.0/24       │  │ 10.0.3.0/24          │ │       │
│  │  │ (private endpoints│  │ (APIM VNet integration│ │       │
│  │  └─────────┬─────────┘  └──────────┬───────────┘ │       │
│  │   NSG ✓    │              NSG ✓    │             │       │
│  └────────────┼───────────────────────┼─────────────┘       │
│               │                       │                     │
│  ┌────────────▼──────────┐  ┌─────────▼──────────────┐      │
│  │ Private Endpoint      │  │ apim-thmp-prod-sc      │      │
│  │  • pe-apim (Gateway)  │  │ API Management         │      │
│  └────────────┬──────────┘  │ Standard v2 / 1 unit   │      │
│               │             │ VNet: External          │      │
│  ┌────────────▼──────────┐  │ SystemAssigned MI       │      │
│  │ Private DNS Zone      │  │ TLS hardened (no RSA)   │      │
│  │ privatelink.          │  └────────────────────────┘      │
│  │   azure-api.net       │                                  │
│  └───────────────────────┘                                  │
│                                                             │
│  ┌──────────────────────┐  ┌──────────────────┐             │
│  │ law-thmp-prod-sc     │  │ ai-thmp-prod-sc  │             │
│  │ Log Analytics        │◄─│ App Insights     │             │
│  │ 30-day retention     │  │ (workspace-based)│             │
│  └──────────┬───────────┘  └──────────────────┘             │
│             │                                               │
│  ┌──────────▼───────────┐                                   │
│  │ Diagnostic Settings  │                                   │
│  │ APIM → LAW           │                                   │
│  │ GatewayLogs + Metrics│                                   │
│  └──────────────────────┘                                   │
└─────────────────────────────────────────────────────────────┘
```

## Resources

| Resource | Terraform ID | Description |
|----------|-------------|-------------|
| Resource Group | `azurerm_resource_group.main` | rg-thmp-prod-sc |
| Virtual Network | `azurerm_virtual_network.main` | 10.0.0.0/16, 2 subnets |
| API Management | `azurerm_api_management.main` | Standard v2 × 1, External VNet |
| Private Endpoint | `azurerm_private_endpoint.apim` | Gateway sub-resource |
| Private DNS Zone | `azurerm_private_dns_zone.apim` | privatelink.azure-api.net |
| Log Analytics | `azurerm_log_analytics_workspace.main` | PerGB2018, 30-day retention |
| Application Insights | `azurerm_application_insights.main` | Workspace-based, local auth disabled |
| Diagnostics | `azurerm_monitor_diagnostic_setting.apim` | GatewayLogs + Metrics → LAW |

## Networking

- **VNet** `10.0.0.0/16` in Sweden Central
- **snet-pe** (`10.0.2.0/24`) — hosts the APIM private endpoint, NSG attached
- **snet-apim** (`10.0.3.0/24`) — APIM VNet integration (delegated), NSG with APIM management rules

## Security Posture

- ✅ Standard v2 SKU with External VNet integration
- ✅ Private endpoint for APIM gateway (privatelink.azure-api.net)
- ✅ System-assigned managed identity on APIM
- ✅ Weak TLS ciphers explicitly disabled (TLS_RSA_*, 3DES)
- ✅ Management API minimum version enforced (2021-08-01)
- ✅ NSGs on all subnets with APIM management inbound rules
- ✅ Application Insights local authentication disabled
- ✅ Workspace-based Application Insights

## Observability

- APIM logger sends telemetry to Application Insights
- Diagnostic settings: APIM `GatewayLogs` + `WebSocketConnectionLogs` → Log Analytics
- All metrics forwarded to Log Analytics (`AllMetrics`)

## Configuration

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `location` | Azure region | `swedencentral` |
| `environment` | Environment name | `dev`, `staging`, `prod` |
| `prefix` | Naming prefix (3-6 lowercase chars) | `thmp` |
| `apim_publisher_name` | APIM publisher display name | `THMP` |
| `apim_publisher_email` | APIM notification email | `admin@thmp.example.com` |

### Optional Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `vnet_address_space` | `["10.0.0.0/16"]` | VNet CIDR |
| `subnet_prefixes` | pe=10.0.2.0/24, apim=10.0.3.0/24 | Subnet CIDRs |
| `apim_sku` | `Standardv2` | APIM tier |
| `apim_capacity` | `1` | APIM scale units |
| `log_analytics_retention_days` | `30` | LAW retention (30–730) |
| `tags` | `{}` | Additional resource tags |

### Naming Convention

All resources follow: `{type}-{prefix}-{environment}-{region_short}`

Example: `apim-thmp-prod-sc`, `vnet-thmp-prod-sc`

## Outputs

| Output | Description | Sensitive |
|--------|-------------|-----------|
| `resource_group_name` / `_id` | Resource group identifiers | No |
| `vnet_name` / `_id` | VNet identifiers | No |
| `apim_name` / `_id` | APIM instance identifiers | No |
| `apim_gateway_url` | APIM gateway endpoint | No |
| `apim_management_api_url` | APIM management endpoint | No |
| `apim_principal_id` | APIM managed identity principal | No |
| `apim_private_ip_addresses` | APIM private IPs | No |
| `log_analytics_workspace_id` / `_name` | LAW identifiers | No |
| `app_insights_connection_string` | App Insights connection | **Yes** |
| `app_insights_instrumentation_key` | App Insights key | **Yes** |

## Deployment

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## Compliance

See [PSRule Compliance Report](psrule-report.md) for Azure Well-Architected Framework analysis.

## File Structure

```
├── main.tf                 # Provider and backend configuration
├── variables.tf            # Input variable definitions
├── locals.tf               # Naming convention and common tags
├── terraform.tfvars        # Environment-specific values
├── resource-group.tf       # Resource group
├── network.tf              # VNet, subnets (pe + apim), NSGs
├── apim.tf                 # API Management (Std v2) + App Insights logger
├── private-endpoints.tf    # APIM private endpoint
├── private-dns.tf          # Private DNS zone + VNet link
├── log-analytics.tf        # Log Analytics Workspace
├── application-insights.tf # Application Insights (workspace-based)
├── diagnostics.tf          # Diagnostic settings → LAW
├── outputs.tf              # Output values
├── ps-rule.yaml            # PSRule configuration
└── docs/
    ├── README.md           # This file
    └── psrule-report.md    # PSRule compliance report
```
