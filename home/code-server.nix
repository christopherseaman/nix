# /etc/nixos/home/code-server.nix
{ config, pkgs, code-server-pkg, ... }:

{
  # Add the code-server package
  home.packages = [ code-server-pkg ];
  
  # Create a systemd user service
  systemd.user.services.code-server = {
    Unit = {
      Description = "VS Code in the browser";
      After = [ "network.target" ];
    };
    Service = {
      # Generate the config file just before starting
      ExecStartPre = ''
        ${pkgs.writeShellScript "generate-code-server-config" ''
          mkdir -p ~/.config/code-server
          echo "bind-addr: 127.0.0.1:8080
auth: password
password: $PASSWORD
cert: false" > ~/.config/code-server/config.yaml
          chmod 600 ~/.config/code-server/config.yaml
        ''}
      '';
      ExecStart = "${code-server-pkg}/bin/code-server";
      Restart = "always";
      EnvironmentFile = "/var/lib/private/secrets.env";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
