#!/bin/bash

set -e -u -o pipefail

# Generate SSH Host Keys (SSH Server ID)
echo -e "\n\033[1mGenerating SSH host keys for initrd...\033[0m"
mkdir -p /mnt/etc/ssh/initrd
ssh-keygen -t ed25519 -f /mnt/etc/ssh/initrd/ssh_host_ed25519_key -N ""
chmod 600 /mnt/etc/ssh/initrd/ssh_host_ed25519_key
echo -e "\033[32mSSH host key generated at /mnt/etc/ssh/initrd/ssh_host_ed25519_key\033[0m"

# Generate SSH Key for github (SSH Client ID)
echo -e "\n\033[1mGenerating SSH keys for github...\033[0m"
mkdir -p /root/.ssh/
ssh-keygen -t ed25519 -f "/root/.ssh/id_ed25519_git" -N ""
eval "$(ssh-agent -s)"
ssh-add /root/.ssh/id_ed25519_git
echo -e "\033[32mSSH key generated for github at /root/.ssh/id_ed25519_git\033[0m"
echo -e "\033[1mSSH public key:\033[0m"
echo -e "\033[34m$(cat ~/.ssh/id_ed25519_git.pub)\033[0m"
echo -e "\033[33mPlease add the public key to your github.\033[0m"

# Convert SSH Host keys to Age (SOPS keys)
echo -e "\n\033[1mConverting SSH host key to Age key...\033[0m"
mkdir -p /mnt/etc/ssh/sops/
nix-shell --extra-experimental-features flakes -p ssh-to-age --run 'ssh-to-age -i /mnt/etc/ssh/initrd/ssh_host_ed25519_key.pub' > /mnt/etc/ssh/sops/age_public_key.txt
nix-shell --extra-experimental-features flakes -p ssh-to-age --run 'ssh-to-age -private-key -i /mnt/etc/ssh/initrd/ssh_host_ed25519_key' > /mnt/etc/ssh/sops/age_private_key.txt
chmod 600 /mnt/etc/ssh/sops/age_public_key.txt
echo -e "\033[32mAge public key generated at /mnt/etc/ssh/sops/age_public_key.txt\033[0m"
echo -e "\033[1mAge public key:\033[0m"
echo -e "\033[34m$(cat /mnt/etc/ssh/sops/age_public_key.txt)\033[0m"
echo -e "\033[33mPlease update your .sops.yaml to include this key, and update your secrets (via nix-shell -p sops --run 'sops updatekeys secrets/secrets.yaml'), then push to github.\033[0m"
