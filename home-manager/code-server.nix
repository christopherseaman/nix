{ config, pkgs, lib, ... }:

{
  home.activation.mkCodeServerDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p /home/christopher/.code-server/data
    mkdir -p /home/christopher/.code-server/extensions
    mkdir -p /home/christopher/projects
    chown -R 1000:100 /home/christopher/.code-server
    chown 1000:100 /home/christopher/projects
  '';

  systemd.user.services.code-server = {
    Unit = {
      Description = "code-server (local binary, user service)";
    };
    Service = {
      # Environment setup
      Environment = [
        "SHELL=${pkgs.fish}/bin/fish"
        "PATH=${lib.makeBinPath [pkgs.coreutils pkgs.nodejs]}:$HOME/.local/bin:$PATH"
      ];
      EnvironmentFile = "/var/lib/secrets.env";
      
      # Use default code-server config locations that work when run manually
      ExecStart = ''
        /home/christopher/.local/bin/code-server --bind-addr 127.0.0.1:8443
      '';
      
      # Service behavior
      Restart = "always";
      RestartSec = 10;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
