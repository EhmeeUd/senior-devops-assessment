#!/usr/bin/env bash
set -e

echo "🚀 Deploying Lambda infrastructure..."

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init -upgrade

# Validate configuration
echo "✅ Validating Terraform configuration..."
terraform validate

# Show plan
echo "📋 Generating deployment plan..."
terraform plan

# Confirm deployment
read -p "🤔 Do you want to apply these changes? (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
  echo "❌ Deployment cancelled"
  exit 1
fi

# Apply changes
echo "⚡ Applying Terraform configuration..."
terraform apply -var-file="terraform.tfvars" -auto-approve

echo "✨ Deployment complete!"
echo ""
echo "📊 Outputs:"
terraform output