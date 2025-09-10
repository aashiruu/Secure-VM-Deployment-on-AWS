```bash
#!/bin/bash
# Automated deployment script
echo "Starting: Secure VM Deployment"
echo "======================================="

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "Terraform not found. Please install Terraform first."
    exit 1
fi

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

# Get current public IP
MY_IP=$(curl -s ifconfig.me)/32
echo "Your public IP: $MY_IP"

# Check if SSH key exists
if [ ! -f ~/.ssh/aws-lab-key.pub ]; then
    echo "SSH key not found. Please create one with:"
    echo "   ssh-keygen -t rsa -b 4096 -f ~/.ssh/aws-lab-key"
    exit 1
fi

SSH_PUB_KEY=$(cat ~/.ssh/aws-lab-key.pub)

echo " Initializing Terraform..."
terraform init

echo " Planning deployment..."
terraform plan -var="ssh_public_key=$SSH_PUB_KEY" -var="my_ip=$MY_IP"

read -p "Continue with deployment? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo " Deploying infrastructure..."
    terraform apply -var="ssh_public_key=$SSH_PUB_KEY" -var="my_ip=$MY_IP" -auto-approve
    
    echo " Deployment complete!"
    echo " Instance Public IP: $(terraform output -raw instance_public_ip)"
    echo " SSH command: ssh -i ~/.ssh/aws-lab-key ec2-user@$(terraform output -raw instance_public_ip)"
else
    echo " Deployment cancelled."
    exit 0
fi
```
