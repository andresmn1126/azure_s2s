variable "ResourceGroups" {
  type = map(any)
}

variable "VirtualNetworkName" {
    type = string
}

variable "AzureSubnets" {
    type = map
}

variable "LocalSubnets" {
    type = map
}

variable "Location" {
    type = string
}

variable "PolicyBasedVPN" {
    type = bool
    description = "If false, vpn type will default to Route Based"
    default = false
}

variable "VPNSKU" {
    type = string
    default = "Basic"
}
