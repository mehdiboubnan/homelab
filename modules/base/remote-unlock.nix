{config, ...}: {
#  boot.kernelParams = ["ip=dhcp"];
  boot.kernelParams = ["ip=192.168.0.235::192.168.0.1:255.255.255.0:my-server-initrd:enp2s0:none"];
  # Found in /sys/class/net/enp2s0/device/driver
  # or with "ethtool -i enp2s0"
  # or with "nix --experimental-features "nix-command" run nixpkgs#lshw -- -C network | grep -Poh 'driver=[[:alnum:]]+'"
  boot.initrd.availableKernelModules = ["r8169"];
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 22;
#      shell = "/bin/cryptsetup-askpass";
      authorizedKeys = config.users.users.mehdi.openssh.authorizedKeys.keys;
      hostKeys = ["/etc/ssh/initrd/ssh_host_ed25519_key"];
    };
#    postCommands = ''
#        # Automatically ask for the password on SSH login
#        echo 'cryptsetup-askpass || echo "Unlock was successful; exiting SSH session" && exit 1' >> /root/.profile
#    '';
  };
}
