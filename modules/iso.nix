{
  ...
}:
{
    users.users.root = {
        openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILVQ5dpjIsUn2XiAGnzcWOFOC1h0rjNoz7BuuN8wpBFZ homelab"
        ];
    };

    programs.bash.shellAliases = {
        install = "sudo bash -c '$(curl -fsSL https://raw.githubusercontent.com/mehdiboubnan/homelab/refs/heads/main/scripts/generate_keys.sh)'";
    };
}
