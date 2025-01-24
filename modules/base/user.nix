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
        openssh.authorizedKeys.keys = [ "<ssh-public-key-to-be-filled>" ]; # Your public key
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