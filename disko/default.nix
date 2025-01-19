{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "to-be-filled-during-installation";
        content = {
          type = "gpt";
          partitions = {
            # EFI partition - Essential for modern UEFI systems
            efi = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/esp";
                extraArgs = [ "-F" "32" "-n" "EFI" ];  # Label the partition
              };
            };
            # Boot pool partition - Encrypted but with GRUB compatibility
            bpool-crypt = {
              size = "4G";
              content = {
                type = "luks";
                name = "cryptboot";
                # Generate with `mkpasswd -m sha-512`
                passwordFile = "/tmp/secret.key";
                settings = {
                  allowDiscards = true;
                  keySize = 512;
                  hashAlgorithm = "sha512";
                };
                content = {
                  type = "zfs";
                  pool = "bpool";
                };
              };
            };
            # Root pool partition - Main system encrypted storage
            rpool-crypt = {
              end = "-1M";
              content = {
                type = "luks";
                name = "cryptroot";
                passwordFile = "/tmp/secret.key";
                settings = {
                  allowDiscards = true;
                  keySize = 512;
                  hashAlgorithm = "sha512";
                };
                content = {
                  type = "zfs";
                  pool = "rpool";
                };
              };
            };
            # BIOS boot partition - For compatibility
            bios = {
              size = "1M";
              type = "EF02";
            };
          };
        };
      };
    };

    zpool = {
      bpool = {
        type = "zpool";
        options = {
          ashift = "12";  # Optimal for most modern disks
          autotrim = "on";
          compatibility = "grub2";
        };
        rootFsOptions = {
          acltype = "posixacl";
          canmount = "off";
          compression = "lz4";  # Fast compression for boot
          devices = "off";
          normalization = "formD";
          relatime = "on";
          xattr = "sa";
          "com.sun:auto-snapshot" = "false";
        };
        mountpoint = "/boot";
        datasets = {
          nixos = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "nixos/root" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/boot";
          };
        };
      };

      rpool = {
        type = "zpool";
        options = {
          ashift = "12";
          autotrim = "on";
          # Additional pool options for homelab
          listsnapshots = "on";
          autoexpand = "on";
        };
        rootFsOptions = {
          acltype = "posixacl";
          canmount = "off";
          compression = "zstd";  # Better compression ratio
          dnodesize = "auto";
          normalization = "formD";
          relatime = "on";
          xattr = "sa";
          "com.sun:auto-snapshot" = "false";
          # Enable snapshots for root filesystem
#          "com.sun:auto-snapshot" = "true";
#          "com.sun:auto-snapshot:frequent" = "false";
#          "com.sun:auto-snapshot:hourly" = "true";
#          "com.sun:auto-snapshot:daily" = "true";
#          "com.sun:auto-snapshot:weekly" = "true";
#          "com.sun:auto-snapshot:monthly" = "true";
        };
        mountpoint = "/";
        datasets = {
          nixos = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          # Separate dataset for system state
          "nixos/var" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              compression = "zstd";
            };
          };
          # Root filesystem with snapshot
          "nixos/empty" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/";
            postCreateHook = "zfs snapshot rpool/nixos/empty@start";
          };
          # Home directories with snapshots enabled
          "nixos/home" = {
            type = "zfs_fs";
            options = {
              mountpoint = "legacy";
              compression = "zstd";
              "com.sun:auto-snapshot" = "true";
            };
            mountpoint = "/home";
          };
          # Logs with compression but no snapshots
          "nixos/var/log" = {
            type = "zfs_fs";
            options = {
              mountpoint = "legacy";
              compression = "zstd";
              "com.sun:auto-snapshot" = "false";
            };
            mountpoint = "/var/log";
          };
          "nixos/var/lib" = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          # NixOS configuration with snapshots
          "nixos/config" = {
            type = "zfs_fs";
            options = {
              mountpoint = "legacy";
              compression = "zstd";
              "com.sun:auto-snapshot" = "false";
              # Enable snapshots
#              "com.sun:auto-snapshot" = "true";
            };
            mountpoint = "/etc/nixos";
          };
          # Persistent data with snapshots
          "nixos/persist" = {
            type = "zfs_fs";
            options = {
              mountpoint = "legacy";
              compression = "zstd";
              "com.sun:auto-snapshot" = "false";
              # Enable snapshots
#              "com.sun:auto-snapshot" = "true";
            };
            mountpoint = "/persist";
          };
          # Nix store with optimized compression
          "nixos/nix" = {
            type = "zfs_fs";
            options = {
              mountpoint = "legacy";
              compression = "zstd";
              "com.sun:auto-snapshot" = "false";
              atime = "off";
            };
            mountpoint = "/nix";
          };
          # Separate datasets for services
          "nixos/services" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              compression = "zstd";
            };
          };
          # Docker with its own dataset
          "nixos/services/docker" = {
            type = "zfs_volume";
            size = "100G";  # Increased for homelab use
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/var/lib/docker";
            };
          };
        };
      };
    };
  };
}
