{ config, pkgs, ... }: {

    environment.systemPackages = with pkgs; [
    zsh
    ];

    # SSH user configuration
    users.users.mehdi = {
        isNormalUser = true;
        description = "mehdi";
        hashedPasswordFile = config.sops.secrets.mehdi_passwd.path;
        extraGroups = [ "wheel" ]; # Enable sudo
        openssh.authorizedKeys.keys = [ # Your public key
            (builtins.readFile config.sops.secrets.ssh_public_key.path)
        ];
        shell = pkgs.zsh;
    };

    # Enable OpenSSH daemon
    services.openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
        };
    };
}