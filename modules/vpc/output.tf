output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "nat_gateway_ip" {
  description = "Useful to confirm from a private-subnet instance that outbound traffic is going through NAT"
  value       = aws_eip.nat.public_ip
}
