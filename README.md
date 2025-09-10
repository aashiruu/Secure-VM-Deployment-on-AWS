# Secure-VM-Deployment-on-AWS
To deploy a secure virtual machine in AWS using Infrastructure as Code (Terraform) with security best practices implemented from the start.

## Prerequisites

### Required Tools
1. **AWS Account** - [Create free account](https://aws.amazon.com/free/)
2. **AWS CLI** - [Installation guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
3. **Terraform** - [Download here](https://developer.hashicorp.com/terraform/downloads)
4. **SSH Client** - Built into Linux/Mac, use Git Bash for Windows

### AWS Setup Steps
1. **Create IAM User** (DO NOT use root account):
   - Go to AWS IAM Console
   - Create user with "Programmatic access"
   - Attach "AdministratorAccess" policy (for learning purposes)
   - Save Access Key ID and Secret Access Key

2. **Configure AWS CLI**:
   ```bash
   aws configure
   # Enter your Access Key, Secret Key, region (us-east-1), and output format (json)
```

1. Create SSH Key Pair:
   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/aws-lab-key
   chmod 400 ~/.ssh/aws-lab-key
   ```

Architecture Overview

```
AWS Cloud
│
├── VPC (10.0.0.0/16) - Isolated network environment
│   │
│   └── Public Subnet (10.0.1.0/24) - Reachable from internet
│       │
│       └── EC2 Instance (t2.micro)
│           │
│           └── Security Group (Firewall)
│               ├── INBOUND: SSH (port 22) from YOUR IP only
│               ├── INBOUND: HTTP (port 80) from anywhere
│               ├── INBOUND: HTTPS (port 443) from anywhere
│               └── OUTBOUND: All traffic to anywhere
```

Step-by-Step Lab Guide

Step 1: Clone and Explore the Lab

```bash
# Clone the repository
git clone https://github.com/your-username/cloud-security-labs.git
cd cloud-security-labs/lab1-vm-deployment

# Explore the Terraform files
cd terraform
ls -la
```

Step 2: Understand the Security Configuration

Open each file to understand what it does:

1. providers.tf - Configures AWS provider and Terraform settings
2. variables.tf - Defines input variables for customization
3. main.tf - Main infrastructure configuration
4. outputs.tf - Defines what information to display after deployment

Step 3: Initialize Terraform

```bash
# Initialize Terraform and download AWS provider
terraform init
```

Expected Output: "Terraform has been successfully initialized!"

Step 4: Plan the Deployment

```bash
# See what Terraform will create (dry run)
terraform plan -var="ssh_public_key=$(cat ~/.ssh/aws-lab-key.pub)" \
               -var="my_ip=$(curl -s ifconfig.me)/32"
```

Review the plan: It should show 6 resources to be created (VPC, subnet, etc.)

Step 5: Deploy the Infrastructure

```bash
# Apply the configuration
terraform apply -var="ssh_public_key=$(cat ~/.ssh/aws-lab-key.pub)" \
                -var="my_ip=$(curl -s ifconfig.me)/32"
```

Type yes when prompted to confirm.

Expected Output: "Apply complete! Resources: 6 added, 0 changed, 0 destroyed."

Step 6: Test the Connection

```bash
# Get the public IP address of your instance
terraform output instance_public_ip

# SSH into the instance (replace with actual IP)
ssh -i ~/.ssh/aws-lab-key ec2-user@YOUR_INSTANCE_IP
```

Success: You should see the Amazon Linux command prompt!

Step 7: Verify Security Settings

```bash
# Check what ports are open (from inside the instance)
sudo netstat -tuln

# Check security group rules (from your local machine)
aws ec2 describe-security-groups --group-ids $(terraform output -raw security_group_id)
```

Step 8: Clean Up (IMPORTANT!)

```bash
# Destroy all resources to avoid AWS charges
terraform destroy -var="ssh_public_key=$(cat ~/.ssh/aws-lab-key.pub)" \
                  -var="my_ip=$(curl -s ifconfig.me)/32"
```

Type yes when prompted.

Expected Output: "Destroy complete! Resources: 6 destroyed."
