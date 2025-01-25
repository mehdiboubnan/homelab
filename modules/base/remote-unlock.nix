{config, ...}: {
  boot.kernelParams = ["ip=dhcp"];
#  boot.initrd.availableKernelModules = ["r8169"];
  boot.initrd.network = {
    enable = true;
    # Specify the network interface name
    static = {
      ip = "192.168.0.236";  # Your desired static IP
      gateway = "192.168.0.1";  # Gateway IP
      netmask = "255.255.255.0";  # Subnet mask
      dns = [ "1.1.1.1" "8.8.8.8" ];  # DNS servers
    };
    ssh = {
      enable = true;
      port = 22;
      shell = "/bin/cryptsetup-askpass";
      authorizedKeys = config.users.users.mehdi.openssh.authorizedKeys.keys;
      hostKeys = ["/etc/ssh/initrd/ssh_host_ed25519_key"];
    };
  };
}
