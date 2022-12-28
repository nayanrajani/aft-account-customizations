variable "cgw_bgp_asn" {
  description = "BGP ASN of the customer gateway"
  type        = string
  default     = "65531"
}

variable "cgw_public_ip" {
  description = "Public IP address of the customer gateway"
  type        = map(string)
  default     = { "cgw_primary" : "", "cgw_secondary" : "" }
}

variable "cgw_vpn_association" {
  description = "VPN association to customer gateway"
  type        = string
  default     = "cgw_primary"
}

variable "cgw_tags" {
  description = "A map of tags to add to all cgw resources"
  type        = map(string)
  default     = { "" : "" }
}

variable "vpn_tags" {
  description = "A map of tags to add to all VPN connections"
  type        = map(string)
  default     = { "Name" : "S2S_PublicGateway" }
}

variable "tgw_id" {
  description = "Transit gateway id."
  type        = string
  default     = "tgw-test"
  validation {
    condition     = length(var.tgw_id) > 4 && substr(var.tgw_id, 0, 4) == "tgw-"
    error_message = "The tgw_id must start with tgw-."
  }
}

variable "enable_static_routing" {
  description = "enable or disable static routing. if disabled, bgp routing will be used"
  type        = bool
  default     = false
}