output "PSK" {
    value = random_password.psk.result
    description = "Value of randomly generated Pre Shared Key"
    sensitive = true
}

data "azurerm_public_ip" "VPNGatewayIP" {
  name                = azurerm_public_ip.VPNGatewayIP.name
  resource_group_name = azurerm_resource_group.rgs["net-rg"].name
  depends_on = [ azurerm_virtual_network_gateway.vpnnetgw ]
}


output "AzurePublicIP" {
    value = data.azurerm_public_ip.VPNGatewayIP.ip_address
}