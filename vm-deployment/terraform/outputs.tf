```hcl
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.lab_vm.public_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.lab_sg.id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.lab_vpc.id
}

output "ssh_connection_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/aws-lab-key ec2-user@${aws_instance.lab_vm.public_ip}"
}
```
