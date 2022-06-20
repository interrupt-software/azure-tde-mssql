#!/bin/bash -l

set -euxo pipefail

sudo systemctl start vault
sudo systemctl status vault

# Sleep 10 seconds to avoid race condition with Vault startup
sleep 10

# Unseal Vault 
vault operator init \
  -format=json \
  -key-shares=1 \
  -key-threshold=1 \
  > vault-unseal.json

export VAULT_UNSEAL=$(cat /root/vault-unseal.json | jq -r '.unseal_keys_b64[0]')
export VAULT_TOKEN=$(cat /root/vault-unseal.json | jq -r '.root_token')

echo "export VAULT_TOKEN=$VAULT_TOKEN" >> /home/vadmin/.bashrc

vault operator unseal $VAULT_UNSEAL

# Sleep 10 seconds to avoid race condition with Vault unseal due to Raft writing to disk
sleep 10

vault login $VAULT_TOKEN

cd /home/vadmin
vault secrets enable -path=vault-admin -version=2 kv
vault kv put vault-admin/vault-unseal @vault-unseal.json  

