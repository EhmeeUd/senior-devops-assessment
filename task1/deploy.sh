#!/usr/bin/env bash
set -e

ENV=$1

if [[ -z "$ENV" ]]; then
  echo "❌ Usage: ./deploy.sh <staging|production>"
  exit 1
fi

TFVARS_FILE="environments/$ENV/terraform.tfvars"

if [[ ! -f "$TFVARS_FILE" ]]; then
  echo "❌ Environment tfvars file not found: $TFVARS_FILE"
  exit 1
fi

echo "🚀 Deploying environment: $ENV"

# Select or create workspace
if terraform workspace select "$ENV" >/dev/null 2>&1; then
  echo "✓ Workspace exists: $ENV"
else
  echo "➕ Creating workspace: $ENV"
  terraform workspace new "$ENV"
  terraform workspace select "$ENV"
fi

terraform init -upgrade

terraform apply -var-file="$TFVARS_FILE" -auto-approve