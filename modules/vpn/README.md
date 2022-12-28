## Module overview
This VPN module creates an customer gateway and then associate it with the VPN connection and transit gateway

## Input variables
| Input Variable  | Description  | Default value | Variable type |
| :------------ |:--------------- | :----- | :----- |
| cgw_bgp_asn | BGP ASN of the customer gateway | "65531" | string |
| cgw_public_ip | Public IP address of the customer gateway | { "cgw_primary" : "", "cgw_secondary" : "" } | map(string |
| cgw_vpn_association | VPN association to customer gateway | "cgw_primary" | string |
| cgw_tags | A map of tags to add to all cgw resources | { "" : "" } | map(string |
| vpn_tags | A map of tags to add to all VPN connections | { "Name" : "S2S_PublicGateway" } | map(string |
| tgw_id | Transit gateway id | "tgw-test" | string |

## Output values
| Output Variable  | Description  |
| :------------ |:--------------- |
| tgw_id | Customer gateway ID |
| vpn_id | The ID of the VPN gateway |
| tgw_vpn_attachment_id | Transit gateway attachment id for the vpn connection |