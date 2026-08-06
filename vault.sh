#!/bin/bash

# Variables
VAULT_ADDR='http://127.0.0.1:8200'
VAULT_TOKEN="${VAULT_TOKEN:?Set VAULT_TOKEN environment variable before running this script}"
SECRET_PATH='secret/kv_bb68a088'
ENV_FILE='./backend/.env'

export VAULT_ADDR
export VAULT_TOKEN

echo "Retrieving secrets from Vault..."
SECRETS=$(docker exec -e VAULT_ADDR="$VAULT_ADDR" -e VAULT_TOKEN="$VAULT_TOKEN" vault vault kv get -format=json "$SECRET_PATH")

if [ $? -ne 0 ]; then
  echo "Failed to retrieve secrets from Vault."
  exit 1
fi

# Extract DB_USER and DB_PASSWORD
DB_USER=$(echo "$SECRETS" | jq -r '.data.data.DB_USER')
DB_PASSWORD=$(echo "$SECRETS" | jq -r '.data.data.DB_PASSWORD')

if [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ]; then
  echo "Failed to extract DB_USER or DB_PASSWORD from Vault secrets."
  exit 1
fi

# Build the .env file, including the full DATABASE_URL for Flask
echo "Saving secrets to $ENV_FILE..."
cat > "$ENV_FILE" << ENVEOF
POSTGRES_USER=$DB_USER
POSTGRES_PASSWORD=$DB_PASSWORD
POSTGRES_DB=exp_db
DATABASE_URL=postgresql://$DB_USER:$DB_PASSWORD@db:5432/exp_db
ENVEOF
if [ $? -ne 0 ]; then
  echo "Failed to save secrets to $ENV_FILE."
  exit 1
fi

echo "Secrets saved successfully to $ENV_FILE"
