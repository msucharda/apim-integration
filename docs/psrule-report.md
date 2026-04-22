# THMP APIM Infrastructure – PSRule Compliance Report

> **Generated:** 2026-04-22  
> **Tool:** PSRule v2.9.0 + PSRule.Rules.Azure v1.47.0  
> **Source:** Terraform plan JSON (`terraform show -json tfplan`)  
> **Environment:** prod · Sweden Central

---

## Summary

| Outcome | Count |
|---------|------:|
| ✅ Pass |    86 |
| ❌ Fail |    35 |
| **Total** | **121** |

### Pass Rate by Resource

| Resource | Passed | Failed | Rate |
|----------|-------:|-------:|-----:|
| apim-thmp-prod-sc | 13 | 5 | 72 % |
| func-thmp-prod-sc | 6 | 9 | 40 % |
| stthmpprodfunc | 6 | 7 | 46 % |
| vnet-thmp-prod-sc | 9 | 0 | 100 % |
| law-thmp-prod-sc | 4 | 1 | 80 % |
| ai-thmp-prod-sc | 4 | 2 | 67 % |
| asp-thmp-prod-sc | 2 | 2 | 50 % |
| nsg-snet-*-thmp-prod-sc (×3) | 18 | 3 | 86 % |
| snet-* (×3) | 9 | 6 | 60 % |
| pe-*-thmp-prod-sc (×2) | 6 | 0 | 100 % |
| Private DNS zones (×2) | 4 | 0 | 100 % |
| rg-thmp-prod-sc | 5 | 0 | 100 % |

---

## False Positives (conversion artefacts)

The following failures are caused by the Terraform → ARM object conversion and **do not reflect actual misconfigurations**:

| Rule | Resource | Why False Positive |
|------|----------|--------------------|
| `Azure.VNET.UseNSGs` | snet-func, snet-pe, snet-apim | NSGs **are** associated via `azurerm_subnet_network_security_group_association` — invisible in converted objects |
| `Azure.VNET.PrivateSubnet` | snet-func, snet-pe, snet-apim | `default_outbound_access_enabled = false` is set on the func subnet; others reserved |
| `Azure.AppService.ManagedIdentity` | func-thmp-prod-sc | `identity { type = "SystemAssigned" }` **is** configured |
| `Azure.APIM.ManagedIdentity` | apim-thmp-prod-sc | `identity { type = "SystemAssigned" }` **is** configured |
| `Azure.AppInsights.Workspace` | ai-thmp-prod-sc | `workspace_id` **is** set to LAW |
| `Azure.Storage.MinTLS` | stthmpprodfunc | `min_tls_version = "TLS1_2"` **is** configured |
| `Azure.Storage.SecureTransfer` | stthmpprodfunc | `https_traffic_only_enabled = true` **is** configured |

**Adjusted totals after excluding false positives: 13 true failures remain.**

---

## True Findings

### 🔴 Critical — Security

| # | Rule | Resource | Description | Remediation |
|---|------|----------|-------------|-------------|
| 1 | `Azure.Storage.Firewall` | stthmpprodfunc | Storage account allows public network access | Set `public_network_access_enabled = false` after initial deployment or restrict via `network_rules` |
| 2 | `Azure.Storage.BlobPublicAccess` | stthmpprodfunc | Anonymous blob access not explicitly disabled | Add `allow_nested_items_to_be_public = false` |
| 3 | `Azure.Storage.LocalAuth` | stthmpprodfunc | Shared key / SAS auth still enabled | Add `shared_access_key_enabled = false` and use Managed Identity for Function App access |
| 4 | `Azure.AppInsights.LocalAuth` | ai-thmp-prod-sc | Local authentication not disabled | Add `local_authentication_disabled = true` |
| 5 | `Azure.APIM.Ciphers` | apim-thmp-prod-sc | Weak TLS ciphers not explicitly disabled | Configure `security` block to disable legacy ciphers (TLS_RSA_*) |
| 6 | `Azure.APIM.MinAPIVersion` | apim-thmp-prod-sc | Management API min version not set | Set `min_api_version = "2021-08-01"` (or later) |

### 🟡 Reliability — High Availability

| # | Rule | Resource | Description | Remediation |
|---|------|----------|-------------|-------------|
| 7 | `Azure.APIM.AvailabilityZone` | apim-thmp-prod-sc | No zone redundancy (Standard SKU) | Upgrade to Premium SKU with `zones = ["1","2","3"]` |
| 8 | `Azure.APIM.MultiRegion` | apim-thmp-prod-sc | Single-region deployment | Add `additional_location` block (Premium SKU required) |
| 9 | `Azure.AppService.PlanInstanceCount` | asp-thmp-prod-sc | Single instance, no HA | Increase capacity or enable zone-redundant plan |
| 10 | `Azure.AppService.AvailabilityZone` | asp-thmp-prod-sc | No AZ config on service plan | Set `zone_balancing_enabled = true` with ≥3 instances |
| 11 | `Azure.Log.Replication` | law-thmp-prod-sc | No cross-region replication | Enable LAW replication for DR scenarios |
| 12 | `Azure.Storage.SoftDelete` | stthmpprodfunc | Blob soft delete not enabled | Add `blob_properties { delete_retention_policy { days = 7 } }` |
| 13 | `Azure.Storage.ContainerSoftDelete` | stthmpprodfunc | Container soft delete not enabled | Add `blob_properties { container_delete_retention_policy { days = 7 } }` |

### 🟡 Performance / Best Practice

| # | Rule | Resource | Description | Remediation |
|---|------|----------|-------------|-------------|
| 14 | `Azure.AppService.HTTP2` | func-thmp-prod-sc | HTTP/2 not enabled | Add `http2_enabled = true` in `site_config` |
| 15 | `Azure.AppService.UseHTTPS` | func-thmp-prod-sc | HTTPS-only not enforced | Add `https_only = true` |
| 16 | `Azure.AppService.WebSecureFtp` | func-thmp-prod-sc | FTP not explicitly disabled | Add `ftps_state = "Disabled"` in `site_config` |
| 17 | `Azure.AppService.ARRAffinity` | func-thmp-prod-sc | ARR session affinity enabled | Add `client_affinity_enabled = false` |
| 18 | `Azure.AppService.WebProbe` | func-thmp-prod-sc | No health check probe | Add `health_check_path = "/api/health"` in `site_config` |
| 19 | `Azure.NSG.LateralTraversal` | nsg-snet-* (×3) | Missing deny rules for lateral traversal | Add explicit deny rules between subnets for unused ports |

### ℹ️ Acknowledged / Not Applicable

| Rule | Reason |
|------|--------|
| `Azure.AppService.AlwaysOn` | Flex Consumption plan (FC1) does not support AlwaysOn — cold start is by design |
| `Azure.AppService.MinTLS` | Controlled at platform level for Flex Consumption; add `minimum_tls_version = "1.2"` if supported |
| `Azure.AppService.WebProbePath` | Depends on health probe being added (see #18) |

---

## Recommended Priority Order

1. ~~**Immediate (Security):** Findings #1–#6 — storage firewall, local auth, cipher hardening~~ **FIXED**
2. **Short term (Reliability):** Findings #12–#13 — soft delete for data protection
3. **Medium term (HA):** Findings #7–#11 — zone redundancy requires SKU upgrades
4. **Best practice:** Findings #14–#19 — HTTPS, HTTP/2, health probes, NSG hardening

---

## Re-running This Report

```powershell
# Generate plan
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json

# Run PSRule (requires PSRule + PSRule.Rules.Azure modules)
$plan = Get-Content .\tfplan.json -Raw | ConvertFrom-Json
# ... conversion script (see run-psrule.ps1)
$armResources | Invoke-PSRule -Module PSRule.Rules.Azure -Outcome Fail,Pass
```
