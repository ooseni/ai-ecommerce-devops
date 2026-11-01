output "public_ip" {
  description = "The node's fixed address, for Ansible and the browser."
  value       = aws_eip.node.public_ip
}

output "shop_url" {
  description = "The shop, once Ansible and Helm have run."
  value       = "http://${aws_eip.node.public_ip}/"
}

output "instance_id" {
  description = "The EC2 instance."
  value       = aws_instance.node.id
}
