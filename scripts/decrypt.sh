#!/bin/bash

# Path to the encrypted secrets.yaml file
export SECRETS_FILE="/mnt/etc/nix-secrets/secrets/secrets.yaml"
export DECRYPTED_SECRETS_PATH="/run/secrets"
export DECRYPTED_FILE="${DECRYPTED_SECRETS_PATH}/secrets.yaml"
export SOPS_AGE_KEY_FILE=/nix/secret/initrd/age_private_key.txt

# Ensure /run/secrets exists
mkdir -p "$DECRYPTED_SECRETS_PATH"

# Decrypt the main secrets.yaml
echo "Decrypting secrets.yaml..."
nix-shell -p sops yq --run '
    sops -d $SECRETS_FILE > $DECRYPTED_FILE' || {
    echo "Failed to decrypt $SECRETS_FILE."
    exit 1
}

# Extract specific secrets
echo "Extracting secrets to individual files..."
nix-shell -p yq --run '
    yq -r '.user_hashed_password' $DECRYPTED_FILE > $DECRYPTED_SECRETS_PATH/user_hashed_password
    yq -r '.ssh_public_key' $DECRYPTED_FILE > $DECRYPTED_SECRETS_PATH/ssh_public_key' || {
    echo "Failed to decrypt $SECRETS_FILE."
    exit 1
}

# Verify the files
echo "Extracted secrets:"
ls -l "$DECRYPTED_SECRETS_PATH"
