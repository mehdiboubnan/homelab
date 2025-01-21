{ config, pkgs, ... }: {
    # SSH user configuration
    users.users.mehdi = {
        isNormalUser = true;
        extraGroups = [ "wheel" ]; # Enable sudo
        openssh.authorizedKeys.keys = [ "|ssh-public-key-to-be-filled|" ]; # Your public key
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