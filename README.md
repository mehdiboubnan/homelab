# :warning: :construction: This is a work in progress :construction: :warning:

# Usage

## ISO preparation

1. Generate an SSH key to connect to your NixOS homelab :
   ```bash
   ssh-keygen -t ed25519 -N "" -C "" -f ~/.ssh/homelab_ed25519_key
   ```
2. Put the public SSH key into the authorized keys of `nixos` user. This will avoid us to use a
   screen and a keyboard, and allow us to connect directly to our homelab when booting on USB.
   ```bash
    HOMELAB_PUBLIC_SSH=$(echo $(cat ~/.ssh/homelab_ed25519_key.pub))
    sed -i "s|<ssh-public-key-to-be-filled>|$HOMELAB_PUBLIC_SSH|" ./modules/iso.nix
    ```
3. Create ISO image
    ```bash
    nix --extra-experimental-features nix-command --extra-experimental-features flakes build .#nixosConfigurations.IsoBuild.config.system.build.isoImage
    ```
   The image is generated in a folder `result/iso`
4. Copy the image into a Ventoy USB. We will configure the USB to boot directly into the custom
   NixOS image, by following this structure :
    ```
    .
    ├── ISO
    │   ├── nixos-custom-x86_64-linux.iso
    └── ventoy
        └── ventoy.json
    ```
   with `ventoy.json` being :
   ```json
   {
     "control": [
       {
         "VTOY_DEFAULT_SEARCH_ROOT": "/ISO"
       },
       {
         "VTOY_MENU_TIMEOUT": "5"
       },
       {
         "VTOY_DEFAULT_IMAGE": "/ISO/nixos-custom-x86_64-linux.iso"
       },
       {
         "VTOY_SECONDARY_BOOT_MENU": "1"
       },
       {
         "VTOY_SECONDARY_TIMEOUT": "5"
       }
     ]
   }
   ```

## Server ISO installation

1. Plug the USB drive to your homelab machine and power it on. It will boot directly into the NixOS
   custom ISO you've just built.
2. Connect to your homelab using SSH with agent forwarding :
   ```bash 
    ssh-add ~/.ssh/homelab_ed25519_key
    ssh -A root@<NIXOS-IP>
   ```
3. Switch to root user and create password :
    ```bash
    sudo su
    passwd
    ```
4. Partition and mount the drives using [disko](https://github.com/nix-community/disko)
    1. Detect the name of your hard drive (preferably SSD or NVMe) using lsblk
        ```bash
        lsblk && ll /dev/disk/by-id/
        DISK='/dev/disk/by-id/<DISK-NAME>'
        ```
    2. Download the `disko` configuration. It will create 4 partitions (1GB EFI partition, 4GB boot
       pool partition, root pool partition using the remaining space, 1MB small BIOS boot partition
       for GRUB)
        ```bash
        curl https://raw.githubusercontent.com/mehdiboubnan/homelab/refs/heads/main/disko/default.nix -o /tmp/disko.nix
        ```
    3. Set your installation disk in the configuration
       ```bash
       sed -i "s|to-be-filled-during-installation|$DISK|" /tmp/disko.nix
       ```
    4. Set an encryption password and save its hash to `/tmp/secret.key`
       ```bash
       mkpasswd -m sha-512 > /tmp/secret.key
       ```
    5. Run partition and mounting
       ```bash
       nix --experimental-features "nix-command flakes" run github:nix-community/disko -- -m destroy,format,mount /tmp/disko.nix
       ```
5. Download and run keys generation script (SSH Host, SSH client, SOPS age)
   ```bash
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/mehdiboubnan/homelab/refs/heads/main/scripts/generate_keys.sh)"
   ```
   :warning: Follow instructions that pops when running the script.
6. Install `git` :
   ```bash
    nix-env -f '<nixpkgs>' -iA git
   ```
7. Clone homelab configuration
   ```bash
    git clone git@github.com:mehdiboubnan/homelab.git /mnt/etc/nixos
   ```
8. Generate your server hardware configuration
    ```bash
    nixos-generate-config --root /mnt
   ```
9. Copy configuration to your homelab machine config, and push it
    ```bash
    cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/machines/<HOSTNAME>/
   ```
8. Install NixOS
    ```bash
    nixos-install \
    --root "/mnt" \
    --no-root-passwd \
    --flake "git+file:///mnt/etc/nixos#<HOSTNAME>" # beraka, etc.
    ```
###

2. Put the public SSH key into the authorized keys of `nixos` user. This will avoid us to use a
   screen and a keyboard, and allow us to connect directly to our homelab when booting on USB.
    1. HOMELAB_PUBLIC_SSH=$(echo $(cat .ssh/homelab_ed25519_key.pub))
    3. sed -i "s|ssh-public-key-to-be-filled|$HOMELAB_PUBLIC_SSH|" ./modules/base/user.nix
10. Copy SSH key to initrd SSH. This will make us able to connect to the server before OS boot.
     ```bash
     exit
     scp ~/.ssh/homelab_ed25519_key root@<NIXOS-IP>:/mnt/nix/secret/initrd/homelab_ed25519_key
     scp ~/.ssh/homelab_ed25519_key.pub root@<NIXOS-IP>:/mnt/nix/secret/initrd/homelab_ed25519_key.pub
     ```

2. Convert this ssh key to an age key that we will use later for sops :
    ```bash
    mkdir -p ~/.config/sops/age/keys.txt
    nix-shell --extra-experimental-features flakes -p ssh-to-age --run 'ssh-to-age -private-key -i ~/.ssh/homelab_ed25519_key' > ~/.config/sops/age/keys.txt
    ```
