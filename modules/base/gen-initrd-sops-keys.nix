{ config, pkgs, ... }: {

systemd.services.generateInitrdSSHKeys = {
  description = "Generate SSH host keys for initrd";
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    ExecStart = ''
      mkdir -p /nix/secret/initrd
      ssh-keygen -t ed25519 -f /nix/secret/initrd/ssh_host_ed25519_key -N ""
    '';
    ExecStartPost = ''
      chmod 600 /nix/secret/initrd/ssh_host_ed25519_key
    '';
  };
};

systemd.services.convertSSHToAge = {
  description = "Convert SSH keys to age keys";
  after = [ "generateInitrdSSHKeys.service" ];
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    ExecStart = ''
      ssh-to-age /nix/secret/initrd/ssh_host_ed25519_key.pub > /nix/secret/initrd/age_key.txt
    '';
  };
};
}
