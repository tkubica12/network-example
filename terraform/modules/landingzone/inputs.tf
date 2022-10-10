variable "location" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "range" {
  type = string
}

variable "p2s_vpn_range" {
  type = string
}

variable "onprem_vpn_ip" {
  type = string
}

variable "onprem_ranges" {
  type = list(string)
}

variable "spoke_count" {
  type = number
}

variable "enable_vpn" {
  type = bool
}

variable "route_onprem_via_firewall" {
  type = bool
}
