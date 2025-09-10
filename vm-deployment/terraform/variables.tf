variable "ssh_public_key" {
  description = "Your public SSH key for EC2 instance access"
  type        = string
}

variable "my_ip" {
  description = "Your public IP address in CIDR format (e.g., 192.168.1.1/32)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"  # Free tier eligible
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
