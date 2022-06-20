#!/bin/bash -l

set -euxo pipefail

sudo apt update && sudo apt upgrade -y
sudo apt-get install unzip -y
sudo apt-get install snapd -y
sudo systemctl enable --now snapd.socket
sudo ln -s /var/lib/snapd/snap /snap
sudo snap install jq

export VAULT_URL="https://releases.hashicorp.com/vault" VAULT_VERSION="1.10.4+ent"

curl \
    --silent \
    --remote-name \
   "${VAULT_URL}/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip"

curl \
    --silent \
    --remote-name \
    "${VAULT_URL}/${VAULT_VERSION}/vault_${VAULT_VERSION}_SHA256SUMS"

curl \
    --silent \
    --remote-name \
    "${VAULT_URL}/${VAULT_VERSION}/vault_${VAULT_VERSION}_SHA256SUMS.sig"

ls -l

unzip vault_${VAULT_VERSION}_linux_amd64.zip

sudo chown root:root vault
sudo mv vault /usr/local/bin/
vault --version
vault -autocomplete-install
complete -C /usr/local/bin/vault vault
sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault

sudo useradd --system --home /etc/vault.d --shell /bin/false vault

sudo mkdir -p /opt/vault/raft/data
sudo chown --recursive vault:vault /opt/vault
HOST_IP=$(ip addr show eth0 | awk -F ' *|:' '/inet /{print $3}' | cut -d / -f 1)

cat << EOF > vault.hcl
ui = true
disable_mlock = true

listener "tcp" {
  address          = "0.0.0.0:8200"
  tls_disable      = "true"
}

storage "raft" {
  path = "/opt/vault/raft/data"
  node_id = "raft_node_1"
}

api_addr = "http://$HOST_IP:8200"
cluster_addr = "https://$HOST_IP:8201"

license_path = "/etc/vault.d/vault.hclic"
EOF


sudo mkdir --parents /etc/vault.d
sudo mv vault.hcl  /etc/vault.d
sudo chown --recursive vault:vault /etc/vault.d
sudo chmod 640 /etc/vault.d/vault.hcl

cat << EOF > vault.service
[Unit]
Description="HashiCorp Vault - A tool for managing secrets"
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault.d/vault.hcl
StartLimitIntervalSec=60
StartLimitBurst=3

[Service]
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
StartLimitInterval=60
StartLimitIntervalSec=60
StartLimitBurst=3
LimitNOFILE=65536
LimitMEMLOCK=infinity
LogRateLimitIntervalSec=0
LogRateLimitBurst=0

[Install]
WantedBy=multi-user.target
EOF

sudo chown root:root vault.service
sudo mv vault.service /usr/lib/systemd/system/
sudo chmod 644 /usr/lib/systemd/system/vault.service
sudo ln -s /usr/lib/systemd/system/vault.service /etc/systemd/system/vault.service

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable vault
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

echo "export VAULT_TOKEN=$VAULT_TOKEN" >> /root/.bashrc

vault operator unseal $VAULT_UNSEAL

# Sleep 10 seconds to avoid race condition with Vault unseal due to Raft writing to disk
sleep 10

vault login $VAULT_TOKEN

cd /root
vault secrets enable -path=vault-admin -version=2 kv
vault kv put vault-admin/vault-unseal @vault-unseal.json  

