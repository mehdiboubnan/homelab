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

  boot.loader.grub = {
    enable = true;
    version = 2;
    devices = [ "/dev/sda" ];
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
