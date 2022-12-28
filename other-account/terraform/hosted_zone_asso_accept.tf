resource "aws_route53_zone_association" "ec2messages_private_r53_zone_association" {
  vpc_id  = aws_vpc.shared_dev_vpc.id
  zone_id = "<zone_id>"
}