resource "random_password" "psk" {
  length  = 32
  upper   = true
  lower   = true
  number  = true
  special = false
}


resource "azurerm_resource_group" "rgs" {
    for_each = var.ResourceGroups

    name = each.value.name
    location = "eastus2"
}

resource "azurerm_virtual_network" "virtual_network" {
  name                = var.VirtualNetworkName
  location            = var.Location
  resource_group_name = azurerm_resource_group.rgs["net-rg"].name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet" "AzureSubnets" {
    for_each = var.AzureSubnets
    
    name = each.value.name
    virtual_network_name = azurerm_virtual_network.virtual_network.name
    resource_group_name = azurerm_resource_group.rgs["net-rg"].name
    address_prefixes = [each.value.subnet] 
}

resource "azurerm_local_network_gateway" "HomeNet" {
    name = var.LocalSubnets.local-net.name
    location = var.Location
    resource_group_name = azurerm_resource_group.rgs["net-rg"].name
    gateway_fqdn = var.LocalSubnets.local-net.FQDN
    address_space = [var.LocalSubnets.local-net.subnet]
}

resource "azurerm_public_ip" "VPNGatewayIP" {
    name = "VPN-IP"
    location = var.Location
    resource_group_name = azurerm_resource_group.rgs["net-rg"].name
    allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "vpnnetgw" {
    name = "VPN-Gateway"
    location = var.Location
    resource_group_name = azurerm_resource_group.rgs["net-rg"].name

    type = "Vpn"
    vpn_type = var.PolicyBasedVPN == true ? "PolicyBased" : "RouteBased"

    active_active = false
    enable_bgp = false
    sku = var.VPNSKU

    ip_configuration {
        public_ip_address_id = azurerm_public_ip.VPNGatewayIP.id
        private_ip_address_allocation = "Dynamic"
        subnet_id                     = azurerm_subnet.AzureSubnets["vpn-net"].id
    }
}

resource "azurerm_virtual_network_gateway_connection" "s2svpn" {
    name = "s2svpn"
    location = var.Location
    resource_group_name = azurerm_resource_group.rgs["net-rg"].name

    type = "IPsec"
    virtual_network_gateway_id = azurerm_virtual_network_gateway.vpnnetgw.id
    local_network_gateway_id = azurerm_local_network_gateway.HomeNet.id

    shared_key = random_password.psk.result
}
