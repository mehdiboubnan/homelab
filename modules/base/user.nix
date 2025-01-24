{ config, pkgs, ... }: {

    environment.systemPackages = with pkgs; [
    zsh
    ];

    # SSH user configuration
    users.users.mehdi = {
        isNormalUser = true;
        description = "mehdi";
        hashedPasswordFile = config.sops.secrets.user_passwd.path;
        extraGroups = [ "wheel" ]; # Enable sudo
        openssh.authorizedKeys.keys = [ # Your public key
            (builtins.readFile config.sops.secrets.ssh_public_key.path or (throw "SSH public key not found"))
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