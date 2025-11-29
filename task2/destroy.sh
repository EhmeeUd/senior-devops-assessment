
#!/usr/bin/env bash
set -e

echo "🔥 Destroying Lambda infrastructure..."

# Confirm destruction
read -p "⚠️  Are you SURE you want to destroy all resources? (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
  echo "❌ Destroy cancelled"
  exit 1
fi

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init -upgrade

# Show what will be destroyed
echo "📋 Generating destroy plan..."
terraform plan -destroy -var-file="terraform.tfvars"

# Final confirmation
read -p "🤔 Proceed with destruction? (yes/no): " final_confirm
if [[ "$final_confirm" != "yes" ]]; then
  echo "❌ Destroy cancelled"
  exit 1
fi

# Destroy resources
echo "💥 Destroying resources..."
terraform destroy -var-file="terraform.tfvars" -auto-approve

echo "✨ All resources destroyed!"