locals {
  rg_name  = "AIVPNRG"
  location = "australiaeast"
}

resource "azurerm_resource_group" "aivpnrg" {
  name     = local.rg_name
  location = local.location
}

resource "azurerm_virtual_network" "vpn_home" {
  name                = "VPN_HOME"
  location            = local.location
  resource_group_name = azurerm_resource_group.aivpnrg.name

  # TODO: 填你 VNet 的 address space（从 Portal -> VNet -> Address space 看）
  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.aivpnrg.name
  virtual_network_name = azurerm_virtual_network.vpn_home.name

  # 你之前命令里用的是 10.0.1.0/24，这里先按这个
  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "vpn_pip" {
  name                = "MyVPNGatewayIP"
  location            = local.location
  resource_group_name = azurerm_resource_group.aivpnrg.name

  # TODO: Portal 里 Public IP 的 allocation method 是 Static 还是 Dynamic？
  allocation_method = "Static"

  # TODO: 如果 Portal 显示 SKU 是 Standard（VPN Gateway 常用），保留；否则改成 Basic
  sku = "Standard"
}

resource "azurerm_virtual_network_gateway" "vpn_gw" {
  name                = "MyVPNGateway"
  location            = local.location
  resource_group_name = azurerm_resource_group.aivpnrg.name

  type = "Vpn"

  # TODO: 这里填你实际的 SKU（例如 VpnGw1 / VpnGw1AZ / VpnGw2 等）
  sku = "VpnGw1"

  # TODO: 绝大多数 S2S 是 route-based；如果你建的是 policy-based 就改成 PolicyBased
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway.id
  }
}

resource "azurerm_local_network_gateway" "homelab" {
  name                = "HomeLab"
  location            = local.location
  resource_group_name = azurerm_resource_group.aivpnrg.name

  # TODO: 填你家路由器公网 IP（on-prem VPN device public IP）
  gateway_address = "125.63.0.18"

  # TODO: 填你 home lab 网段（on-prem address space，比如 192.168.50.0/24）
  address_space = ["192.168.100.0/24"]
}

resource "azurerm_virtual_network_gateway_connection" "s2s" {
  name                = "AzureToHomeLab"
  location            = local.location
  resource_group_name = azurerm_resource_group.aivpnrg.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_gw.id
  local_network_gateway_id   = azurerm_local_network_gateway.homelab.id

  # TODO: 这里填你配置连接时用的 PSK（Shared Key）
  shared_key = "REPLACE_ME"
}
