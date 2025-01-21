{ config, inputs, pkgs, ... }: {
  imports = [
    # Import sops-nix module from flake inputs
    inputs.sops-nix.nixosModules.sops
  ];

  # Install necessary tools
  environment.systemPackages = with pkgs; [
    sops
    age
    ssh-to-age
  ];

  # System-wide SOPS configuration
  sops = {
    defaultSopsFile = ./../../secrets/secrets.yaml;
    age.sshKeyPaths = ["/nix/secret/initrd/ssh_host_ed25519_key"];
#    secrets."user-password".neededForUsers = true;
#    secrets."user-password" = {};
  };
#  sops = {
#    age.keyFile = "/var/lib/sops-nix/key.txt";
    # This will add secrets.yml to the nix store
    # You can avoid this by adding a string to the full path instead, i.e.
    # sops.defaultSopsFile = "/root/.sops/secrets/example.yaml";
#    defaultSopsFile = ./secrets/secrets.yaml;
    # This will automatically import SSH keys as age keys
#    age.sshKeyPaths = [ "/etc/ssh/keys/age_key.txt" ];
    # This is using an age key that is expected to already be in the filesystem
#    age.keyFile = "/var/lib/sops-nix/key.txt";
    # This will generate a new key if the key specified above does not exist
#    age.generateKey = true;
    # This is the actual specification of the secrets.
#    secrets.example-key = {};
#    secrets."myservice/my_subdir/my_secret" = {};
#  };


}
