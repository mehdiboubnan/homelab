#!/usr/bin/env bash

set -e -u -o pipefail

# Generate SSH Host Keys (SSH Server ID)
echo -e "\n\033[1mGenerating SSH host keys for initrd...\033[0m"
mkdir -p /nix/secret/initrd
ssh-keygen -t ed25519 -f /nix/secret/initrd/ssh_host_ed25519_key -N ""
chmod 600 /nix/secret/initrd/ssh_host_ed25519_key
echo -e "\033[32mSSH host key generated at /nix/secret/initrd/ssh_host_ed25519_key\033[0m"

# Generate SSH Key for github (SSH Client ID)
echo -e "\n\033[1mGenerating SSH keys for github...\033[0m"
mkdir -p /mnt/home/mehdi/
ssh-keygen -t ed25519 -f "~/.ssh/id_ed25519_git" -N ""
echo -e "\033[32mSSH key generated for github at ~/.ssh/id_ed25519_git\033[0m"
echo -e "\033[1mSSH public key:\033[0m"
echo -e "\033[34m$(cat ~/.ssh/id_ed25519_git.pub)\033[0m"
echo -e "\033[33mPlease add the public key to your github.\033[0m"

# Convert SSH Host keys to Age (SOPS keys)
echo -e "\n\033[1mConverting SSH host key to Age key...\033[0m"
ssh-to-age /nix/secret/initrd/ssh_host_ed25519_key.pub > /nix/secret/initrd/age_public_key.txt
chmod 600 /nix/secret/initrd/age_public_key.txt
echo -e "\033[32mAge public key generated at /nix/secret/initrd/age_public_key.txt\033[0m"
echo -e "\033[1mAge public key:\033[0m"
echo -e "\033[34m$(cat /nix/secret/initrd/age_public_key.txt)\033[0m"
echo -e "\033[33mPlease update your .sops.yaml to include this key, update your secrets afterwards and push to github.\033[0m"
