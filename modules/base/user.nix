{ config, pkgs, ... }: {

    environment.systemPackages = with pkgs; [
    zsh
    ];

    # SSH user configuration
    users.users.mehdi = {
        isNormalUser = true;
        description = "mehdi";
        hashedPasswordFile = config.sops.secrets.user_hashed_password.path;
        extraGroups = [ "wheel" ]; # Enable sudo
        openssh.authorizedKeys.keys = [ # Your public key
            config.sops.secrets.ssh_public_key.contents
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