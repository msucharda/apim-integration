location    = "swedencentral"
environment = "prod"
prefix      = "igw"

# APIM
apim_sku             = "StandardV2"
apim_capacity        = 1
apim_publisher_name  = "thmp"
apim_publisher_email = "podpora@thmp.cz"

# Networking
vnet_address_space = ["10.88.8.0/23"]
subnet_prefixes = {
  pe   = "10.88.9.0/24"
  apim = "10.88.8.0/24"
}

# Observability
log_analytics_retention_days = 30

# Landing zone DNS
private_dns_zone_apim_id = "/subscriptions/0a732bd1-d252-4375-9ef1-8d012b56e9f4/resourceGroups/rg-hub-dns-swedencentral/providers/Microsoft.Network/privateDnsZones/privatelink.azure-api.net"
