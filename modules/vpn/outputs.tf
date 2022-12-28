#Outputs
# Export the customer gateway id
output "cgw_id" {
  description = "The ID of the customer gateway"
  value       = { for k, v in aws_customer_gateway.cust_gateway : k => v.id }
}

output "vpn_id" {
  description = "The ID of the VPN gateway"
  value       = aws_vpn_connection.s2s_vpngateway
}

output "tgw_vpn_attachment_id" {
  description = "TGW attachment id for the vpn"
  value       = aws_vpn_connection.s2s_vpngateway.transit_gateway_attachment_id
}