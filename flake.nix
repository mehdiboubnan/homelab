{
  description = "MehLab";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-secrets = {
      url = "git+ssh://git@github.com/mehdiboubnan/nix-secrets?shallow=1&ref=main";
      flake = false;
    };

  };

  outputs = { ... } @ inputs:
  let
    secretspath = builtins.toString inputs.nix-secrets;
  in
  {
    nixosConfigurations = {
      IsoBuild = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs ;};
        modules = [./modules/iso.nix];
        modules = [
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ./modules/iso.nix
        ];
      };
      braka = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [./machines/braka/configuration.nix];
      };
    };
  };
}
