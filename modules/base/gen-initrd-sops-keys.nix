{ config, pkgs, ... }: {

  # Service to generate SSH host keys for initrd
  systemd.services.generateInitrdSSHKeys = {
    description = "Generate SSH host keys for initrd";
    wantedBy = [ "multi-user.target" ];
    conditionConfig = {
      # Run only if the key doesn't already exist
      ConditionPathExists = "!/nix/secret/initrd/ssh_host_ed25519_key";
    };
    serviceConfig = {
      ExecStart = ''
        echo "Generating SSH host keys for initrd..."
        mkdir -p /nix/secret/initrd
        ssh-keygen -t ed25519 -f /nix/secret/initrd/ssh_host_ed25519_key -N ""
        chmod 600 /nix/secret/initrd/ssh_host_ed25519_key
        echo "SSH host key generated at /nix/secret/initrd/ssh_host_ed25519_key"
      '';
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # Service to convert SSH keys to Age keys
  systemd.services.convertSSHToAge = {
    description = "Convert SSH host keys to Age keys";
    after = [ "generateInitrdSSHKeys.service" ];
    wantedBy = [ "multi-user.target" ];
    conditionConfig = {
      # Run only if the Age key doesn't already exist
      ConditionPathExists = "!/nix/secret/initrd/age_public_key.txt";
    };
    serviceConfig = {
      ExecStart = ''
        echo "Converting SSH host key to Age key..."
        ssh-to-age /nix/secret/initrd/ssh_host_ed25519_key.pub > /nix/secret/initrd/age_public_key.txt
        chmod 600 /nix/secret/initrd/age_public_key.txt
        echo "Age public key generated at /nix/secret/initrd/age_public_key.txt"
        echo "Age public key:"
        cat /nix/secret/initrd/age_public_key.txt
        echo "Please update your .sops.yaml to include this key, and update your secrets afterwards."
      '';
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

}
