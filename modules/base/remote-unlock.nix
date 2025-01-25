{config, ...}: {
  boot.kernelParams = ["ip=dhcp"];
  # Found in /sys/class/net/enp2s0/device/driver or with "ethtool -i enp2s0"
  boot.initrd.availableKernelModules = ["r8169"];
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 22;
      shell = "/bin/cryptsetup-askpass";
      authorizedKeys = config.users.users.mehdi.openssh.authorizedKeys.keys;
      hostKeys = ["/etc/ssh/initrd/ssh_host_ed25519_key"];
    };
  };
}
