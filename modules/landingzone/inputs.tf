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

variable "onprem_vpn_ip" {
  type = string
}

variable "spoke_count" {
  type = number
}

variable "enable_vpn" {
  type = bool
}

variable "bgp_asn" {
  type = number
}

variable "bgp_peer_asn" {
  type = number
}

variable "bgp_peer_ip" {
  type = string
}
