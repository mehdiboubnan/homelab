{
  inputs,
  outputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./../../modules/base/user.nix
    ./../../modules/base/gen-initrd-sops-keys.nix
    ./../../modules/base/remote-unlock.nix
    ./../../modules/base/sops.nix
  ];
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
