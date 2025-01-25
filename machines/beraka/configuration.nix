{
  inputs,
  outputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./../../modules/base/user.nix
    ./../../modules/base/remote-unlock.nix
    ./../../modules/base/sops.nix
  ];

  networking = {
    hostName = "beraka";
    hostId = "d3d5eb79"; # hostid=$(echo -n "$hostname" | md5sum | cut -c1-8)
    firewall = {
      enable = true;
    };
  };

#  boot.loader.grub = {
#    enable = true;
#    devices = [ "/dev/sda" ];
#    enableCryptodisk = true; # Enable cryptodisk support
#  };

  boot.loader.grub = {
  enable = true;
  device = "nodev";
  enableCryptodisk = true;  # Enables GRUB to decrypt the boot pool
  efiSupport = true;       # Required for UEFI systems
  fsIdentifier = "label";
};

}
  # Machine-specific secrets if needed
#  sops.secrets.machine_specific_secret = {
#    sopsFile = ./secrets.yaml;
#  };

#  home-manager = {
#    extraSpecialArgs = {inherit inputs outputs;};
#    useGlobalPkgs = true;
#    useUserPackages = true;
#    users = {
#      eh8 = {
#        imports = [
#          ./../../modules/home-manager/base.nix
#        ];
#      };
#    };
#  };

#  networking.hostName = "svr2chng";
#}
