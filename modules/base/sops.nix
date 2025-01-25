{ config, inputs, pkgs, ... }:
let
    secretspath = builtins.toString inputs.nix-secrets;
in
{
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
    defaultSopsFile = "${inputs.nix-secrets}/secrets/secrets.yaml";
    age.sshKeyPaths = ["/etc/ssh/initrd/ssh_host_ed25519_key"];
    secrets."user_hashed_password" = {
        neededForUsers = true;
    };
    secrets."ssh_public_key" = {};
#        format = "string";
    };

}
