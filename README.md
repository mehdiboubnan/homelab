# Usage

1. Generate an SSH key to connect to your NixOS homelab :
   ```bash
   ssh-keygen -t ed25519 -N "" -C "" -f ~/.ssh/homelab_ed25519_key
   ```
2. Put the public SSH key into the authorized keys of `nixos` user. This will avoid us to use a
   screen and a keyboard, and allow us to connect directly to our homelab when booting on USB.
    1. HOMELAB_PUB_SSH=$(echo $(cat .ssh/homelab_ed25519_key.pub))
    2. sed -i "s|ssh-public-key-to-be-filled|$HOMELAB_PUB_SSH|" ./flake.nix
3. Create ISO image
    ```bash
    nix --experimental-features "nix-command flakes" nix build .#nixosConfigurations.iso.config.system.build.isoImage
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
5. Plug the USB drive to your homelab machine, it will boot directly into the NixOS custom ISO
   you've just built.
6. Connect to your homelab using SSH with agent forwarding :
   ```bash 
    ssh-add ~/.ssh/homelab_ed25519_key
    ssh -A nixos@<NIXOS-IP>
   ```
7. Switch to root user and create password :
    ```bash
    sudo su
    passwd
    ```
8. Partition and mount the drives using [disko](https://github.com/nix-community/disko)
    1. Detect the name of your hard drive (preferably SSD or NVMe) using lsblk
        ```bash
        DISK='/dev/disk/by-id/<DISK-NAME>'
        ```
    2. Download the `disko` configuration. It will create 4 partitions (1GB EFI partition, 4GB boot
       pool partition, root pool partition using the remaining space, 1MB small BIOS boot partition
       for GRUB)
        ```bash
        curl https://raw.githubusercontent.com/notthebee/nix-config/main/disko/zfs-root/default.nix -o /tmp/disko.nix
        ```
    3. Set your installation disk in the configuration
       ```bash
       sed -i "s|to-be-filled-during-installation|$DISK|" /tmp/disko.nix
       ```
    4. Run partition and mounting
       ```bash
       nix --experimental-features "nix-command flakes" run github:nix-community/disko -- -m destroy,format,mount /tmp/disko.nix
       ```
9. Install `git` :
   ```bash 
    nix-env -f '<nixpkgs>' -iA git
   ```
10. Clone this repository into `/mnt/etc/nixos`
    ```bash 
     git clone https://github.com/mehdiboubnan/nixos.git /mnt/etc/nixos
    ```