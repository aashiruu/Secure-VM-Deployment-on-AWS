# Create a dedicated VPC (Virtual Private Cloud)
resource "aws_vpc" "lab_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Security-Lab-VPC"
  }
}

# Create an Internet Gateway for public internet access
resource "aws_internet_gateway" "lab_igw" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "Lab-Internet-Gateway"
  }
}

# Create a public subnet within the VPC
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"  # Change based on your region
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet"
  }
}

# Create route table for public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_igw.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

# Associate route table with public subnet
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Create security group (firewall) for the EC2 instance
resource "aws_security_group" "lab_sg" {
  name        = "lab-security-group"
  description = "Allow SSH from my IP and HTTP/HTTPS from anywhere"
  vpc_id      = aws_vpc.lab_vpc.id

  # Allow SSH access only from my IP
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # Allow HTTP access from anywhere
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS access from anywhere
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Lab-Security-Group"
  }
}

# Create EC2 instance
resource "aws_instance" "lab_vm" {
  ami                    = "ami-0c02fb55956c7d316"  # Amazon Linux 2023
  instance_type          = var.instance_type
  key_name               = aws_key_pair.lab_key.key_name
  vpc_security_group_ids = [aws_security_group.lab_sg.id]
  subnet_id              = aws_subnet.public_subnet.id

  tags = {
    Name = "Security-Lab-VM"
  }

  # Ensure instance gets a public IP
  associate_public_ip_address = true
}

# Create SSH key pair
resource "aws_key_pair" "lab_key" {
  key_name   = "lab-ssh-key"
  public_key = var.ssh_public_key

  tags = {
    Name = "Lab-SSH-Key"
  }
}
