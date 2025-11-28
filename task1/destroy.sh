#!/usr/bin/env bash
set -e

ENV=$1

if [[ -z "$ENV" ]]; then
  echo "❌ Usage: ./destroy.sh <staging|production>"
  exit 1
fi

TFVARS_FILE="environments/$ENV/terraform.tfvars"

if [[ ! -f "$TFVARS_FILE" ]]; then
  echo "❌ Environment tfvars file not found: $TFVARS_FILE"
  exit 1
fi

echo "🔥 Destroying environment: $ENV"

# Confirm destruction if production
if [[ "$ENV" == "production" ]]; then
  read -p "⚠️  Are you SURE you want to destroy PRODUCTION? (yes/no): " ans
  if [[ "$ans" != "yes" ]]; then
    echo "❌ Destroy cancelled"
    exit 1
  fi
fi

terraform init -upgrade

# Select workspace OR fail if not found
if terraform workspace select "$ENV" >/dev/null 2>&1; then
  echo "Using workspace: $ENV"
else
  echo "❌ Workspace '$ENV' does not exist."
  exit 1
fi

terraform destroy -var-file="$TFVARS_FILE" -auto-approve